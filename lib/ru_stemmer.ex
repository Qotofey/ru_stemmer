defmodule RuStemmer do
  @one_syllable_rx ~r/.*[аеиоуыэюя].*/u
  @two_syllables_rx ~r/.*[аеиоуыэюя].*[аеиоуыэюя].*/u
  @tree_syllables_rx ~r/.*[аеиоуыэюя].*[аеиоуыэюя].*[аеиоуыэюя].*/u

  @perfect_gerund_rx ~r/((ив|ивши|ившись|ыв|ывши|ывшись)|(([ая])(в|вши|вшись)))$/u
  @reflexive_rx ~r/(с[яь])$/u
  @adjective_rx ~r/(ее|ие|ые|ое|ими|ыми|ей|ий|ый|ой|ем|им|ым|ом|его|ого|ему|ому|их|ых|ую|юю|ая|яя|ою|ею)$/u
  @participle_rx ~r/((ивш|ывш|ующ)|(([ая])(ем|нн|вш|ющ|щ)))$/u
  @verb_rx ~r/((ила|ыла|ена|ейте|уйте|ите|или|ыли|ей|уй|ил|ыл|им|ым|ен|ило|ыло|ено|ят|ует|уют|ит|ыт|ены|ить|ыть|ишь|ую|ю)|(([ая])(ла|на|ете|йте|ли|й|л|ем|н|ло|но|ет|ют|ны|ть|ешь|нно)))$/u
  @noun_rx ~r/(а|ев|ов|ие|ье|е|иями|ями|ами|еи|ии|и|ией|ей|ой|ий|й|иям|ям|ием|ем|ам|ом|о|у|ах|иях|ях|ы|ь|ию|ью|ю|ия|ья|я)$/u
  @superlative_rx ~r/(ейше|ейш)$/u

  def stem(input) do
    cond do
      is_list(input) -> input |> Stream.map(&(stem(&1))) |> Enum.to_list
      input =~ " "   -> input |> String.split() |> stem()
      true           -> RuStemmer.apply(input)
    end
  end

  def apply(word) do
    word
    |> String.downcase
    |> String.replace("ё", "е")
    |> cut
  end

  def cut(word) do
    cond do
      one_syllable?(word) -> one_syllable(word)
      true                -> word
    end
  end

  def one_syllable(word) do
    cond do
      two_syllable?(word) -> two_syllable(word)
      true                -> word
    end
    |> String.replace(~r/нн?$/u, "н")
    |> String.replace(~r/ь?$/u, "")
  end

  def two_syllable(word) do
    word
    |> cut_ends
    |> String.replace(~r/(и)$/u, "")
    |> tree_syllable
    |> String.replace(@superlative_rx, "")
  end

  def cut_ends(word) do
    perfect_gerund = String.replace(word, @perfect_gerund_rx, "\\4")

    word = String.replace(word, @reflexive_rx, "")
    adjective = String.replace(word, @adjective_rx, "")
    verb = String.replace(word, @verb_rx, "\\4")
    noan = String.replace(word, @noun_rx, "")

    cond do
      word != perfect_gerund -> perfect_gerund
      word != adjective      -> String.replace(adjective, @participle_rx, "\\4")
      word != verb           -> verb
      word != noan           -> noan
      true                   -> word
    end
  end

  def tree_syllable(word) do
    cond do
      tree_syllable?(word) -> String.replace(word, ~r/ость?$/u, "")
      true                 -> word
    end
  end

  def one_syllable?(word), do: Regex.match?(@one_syllable_rx, word)
  def two_syllable?(word), do: Regex.match?(@two_syllables_rx, word)
  def tree_syllable?(word), do: Regex.match?(@tree_syllables_rx, word)
end
