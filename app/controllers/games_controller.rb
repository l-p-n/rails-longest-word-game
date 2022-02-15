require 'open-uri'
require 'json'

class GamesController < ApplicationController
  # RULES:
  # The word can’t be built out of the original grid
  # The word is valid according to the grid, but is not a valid English word
  # The word is valid according to the grid and is an English word

  VOWELS = %w(A E I O U Y)

  def new
    @letters = Array.new(4) { VOWELS.sample }
    @letters += Array.new(6) { (('A'..'Z').to_a - VOWELS).sample }
    @letters.shuffle!
  end

  def score
    @letters = params[:letters].split.join(", ")
    @word = (params[:word] || "").upcase
    @included = included?(@word, @letters)
    @english_word = english_word?(@word)

    @result = ''
    if @included == false && @english_word == true
      @result = "Sorry, but #{@word} can't be built out of #{@letters}"
    elsif @english_word == false
      @result = "Sorry but #{@word} does not seem to be a valid English word..."
    else
      @result = "Congratulations! #{@word} is a valid English word!"
    end
  end

  private

  def included?(word, letters)
    # The all?() of enumerable is an inbuilt method in Ruby
    # Returns true if all the objects in the enumerable satisfy the given condition, else it returns false.
    # Syntax enu.all? { |obj| block }
    word.chars.all? { |letter| word.count(letter) <= letters.count(letter) }
  end

  def english_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    response = URI.open(url).read
    json = JSON.parse(response)
    json['found']
  end
end
