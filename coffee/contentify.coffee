contentify = null
do ($) ->
	class Contentify
		constructor: ->
			@raw = {}
			@content = {}

		initialize: (@owner, @repo, mode) ->
			if not mode
				@mode = 'release'
			else
				@mode = mode

		clearCache: (filename) ->
			if filename
				delete @raw[filename]
				delete @content[filename]
			else
				delete @raw
				delete @content

		getBaseUrl: () ->
			return 'https://api.github.com/repos/' + @owner + '/' + @repo + '/contents/'

		clearCache: (filename) ->
			if filename
				delete @raw[filename]
				delete @content[filename]
			else
				delete @raw
				delete @content

		getExtension: (filename) ->
			res = filename.match /[a-zA-Z0-9-_]+\.([a-z]{1,4})/i
			return res[1]

		getSlug: (filename) ->
			res = filename.match /([a-zA-Z0-9-_]+)\.[a-z]{1,4}/i
			return res[1]

		getContentRaw: (filename, callback) ->
			return callback 'no file' if not filename

			return callback null, @raw[filename] if @raw[filename]
			branch = 'master'
			if @mode == 'draft'
				branch = @getSlug filename

			$.ajax
				url: @getBaseUrl() + filename + "?ref=" + branch
				headers:
				    'Accept': 'application/vnd.github.V3.raw'
				success: (data) =>
					@raw[filename] = data
					return callback null, data

		compile: (data) ->
			regexp = /[^ `]\[\[ ?fragment ([a-zA-Z0-9-_]+) ?\]\]((.*\s*)*?)\[\[ ?\/fragment ?\]\]/gi
			res = data.match regexp
			return marked(data) if not res
			results = {}
			regexp = /\[\[ ?fragment ([a-zA-Z0-9-_]+) ?\]\]((.*\s*)*?)\[\[ ?\/fragment ?\]\]/i
			for fragment in res
				match = fragment.match(regexp)
				results[match[1]] = marked(match[2].trim())
			return results

		getContent: (filename, fragment, callback) ->
			if not callback
				callback = fragment
				fragment = null

			return callback "filename null" if not filename
			if @content[filename]
				return callback null, @content[filename] if not fragment
				return callback null, @content[filename][fragment] if typeof fragment == 'string' and @content[filename][fragment]
				if fragment?.length > 0
					c = []
					for f in fragment
						c.push @content[filename][f] if @content[filename][f]
					return callback null, c

			@getContentRaw filename, (err, data) =>
				return callback 'No data in ' + filename if err or not data

				if @getExtension(filename) == 'md'
					data = @compile data

				@content[filename] = data

				if fragment
					return callback null, data[fragment] if typeof fragment == 'string' and data[fragment]
					if fragment.length > 0
						c = []
						for f in fragment
							c.push data[f] if data[f]
						return callback null, c

				return callback null, data

	contentify = new Contentify()


	$.fn.includeContent = ( filename, fragment, callback ) ->
		defaults =
			owner: null
			repo: null
			filename: null
			fragment: null

		if typeof fragment != 'string'
			callback = fragment
			fragment = null

		settings = $.extend {}, defaults, filename: filename, fragment: fragment

		return this.each ->
			contentify.getContent settings.filename, settings.fragment, (err, content) =>
				$(@).html error if err
				$(@).html content if not err
				callback $(@) if callback