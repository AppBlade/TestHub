module ApplicationHelper

  def sentenceficate(strings, captialize: true, periodficate: true)
    strings = Array(strings)
    if strings.select {|string| string.include? ',' }.any?
      sentence = strings.to_sentence(:words_connector => '; ', :last_word_connector => '; and ', :two_words_connector => '; and ') 
    else
      sentence = strings.to_sentence
    end
    sentence[0] = sentence[0].capitalize if captialize
    sentence << '.' if periodficate
    sentence
  end

end
