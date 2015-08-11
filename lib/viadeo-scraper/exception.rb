#encoding: utf-8

##
## exception.rb
## Gaetan JUVIN 27/07/2015
##

module Viadeo
  class UnknownLanguage < StandardError
  	attr_reader :word

	def initialize(word)
		@word = word
	end
  end
end