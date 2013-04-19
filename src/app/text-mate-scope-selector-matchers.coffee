class SegmentMatcher
  constructor: (segment) ->
    @segment = segment.join('')

  matches: (scope) ->
    scope is @segment

class AsteriskMatcher
  constructor: ->

  matches: ->
    true

class ScopeMatcher
  constructor: (first, others) ->
    @segments = [first]
    @segments.push(segment[1]) for segment in others

  matches: (scope) ->
    scopeSegments = scope.split('.')
    if scopeSegments.length < @segments.length
      return false

    for segment, index in @segments
      unless segment.matches(scopeSegments[index])
        return false
    true

class PathMatcher
  constructor: (first, others) ->
    @matchers = [first]
    @matchers.push(matcher[1]) for matcher in others

  matches: (scopes) ->
    index = 0
    matcher = @matchers[index]
    for scope in scopes
      matcher = @matchers[++index] if matcher.matches(scope)
      return true unless matcher?
    false

class OrMatcher
  constructor: (@left, @right) ->

  matches: (scopes) ->
    @left.matches(scopes) or @right.matches(scopes)

class AndMatcher
  constructor: (@left, @right) ->

  matches: (scopes) ->
    @left.matches(scopes) and @right.matches(scopes)

class NegateMatcher
  constructor: (@left, @right) ->

  matches: (scopes) ->
    @left.matches(scopes) and not @right.matches(scopes)

class CompositeMatcher
  constructor: (left, operator, right) ->
    switch operator
      when '|' then @matcher = new OrMatcher(left, right)
      when '&' then @matcher = new AndMatcher(left, right)
      when '-' then @matcher = new NegateMatcher(left, right)

  matches: (scopes) ->
    @matcher.matches(scopes)

module.exports = {
  AndMatcher
  AsteriskMatcher
  CompositeMatcher
  NegateMatcher
  OrMatcher
  PathMatcher
  ScopeMatcher
  SegmentMatcher
}
