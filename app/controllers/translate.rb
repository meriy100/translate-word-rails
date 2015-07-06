#!/usr/bin/env ruby

require "open-uri"
require "nokogiri"
require "lemmatizer"

  def translate_en_to_jp(word_en)
    # (1) 英単語の単語ItemIdを取得
    enc_word = URI.encode(word_en)
         # http://public.dejizo.jp/NetDicV09.asmx/SearchDicItemLite?
    dejizo_api_s =  "http://public.dejizo.jp/NetDicV09.asmx/SearchDicItemLite?"
    dejizo_api_g = "http://public.dejizo.jp/NetDicV09.asmx/GetDicItemLite?"
    dic = "EJdict"
    scope = "HEADWORD"
    match =  "EXACT"
    merge = "OR"
    prof =  "XHTML"
    pageSize =  "20"
    pageIndex =  "0"
    url =  dejizo_api_s            +
          "Dic="        + dic      + 
          "&Word="      + enc_word +
          "&Scope="     + scope    +
          "&Match="     + match    + 
          "&Merge="     + merge    +
          "&Prof="      + prof     +
          "&PageSize="  + pageSize +
          "&PageIndex=" + pageIndex 
    begin
      xml = open(url).read
      doc = Nokogiri::XML(xml)
      item_id = doc.search('ItemID').first.inner_text rescue nil
      return nil unless item_id

      # (2)英単語のItemIdから翻訳を取得
      url = dejizo_api_g        +
            "Dic="   + dic      +
            "&Item=" + item_id  +
            "&Loc="  + "&Prof=" + prof
      
      xml = open(url).read
      doc = Nokogiri::XML(xml)
      text = doc.search('Body').inner_text rescue nil
      text.gsub!(/(\r\n|\r|\n|\t|\s)/, '')
      return text  
    
    rescue Exception => e
      puts e        
    end
    
  end

def list_cut_length list, len
  rem = len - list.first.length unless list.empty?
  if list.empty?
    ""
  elsif rem > 0
    list.shift + list_cut_length(list, rem)
  else
    list.shift 
  end
end

def leaf_parse doc
  ja_list = []
  div_list  = doc.css "div"
  ch_list = nil
  div_list.each do |cell|
    if attr_class = cell.attributes['class']
      if attr_class.value == "contents-wrap-b-in"
        ch_list = cell.children 
        break
      end
    end
  end
  ch_list.each do |ch|
    if ch_attr_class = ch.attributes['class']
      if ch_attr_class.value =="content-box"
        ch.css('li').each do |li|
          if li.attributes["class"].value == "in-ttl-b text-indent"
            ja_list.push li.inner_text
          end
        end
      end
    end
  end
  ja_list
end


def translate_goo_en_to_ja word_en, output = :one  
  ja_list = []
  goo_home ="http://dictionary.goo.ne.jp"
  goo_url="#{goo_home}/srch/ej/#{word_en}/m0u/"
  userAgent = "Mozilla/#{rand 100}.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; "  
  begin
    html = open(goo_url,"User-Agent"=>userAgent).read
    doc = Nokogiri::HTML(html)
    return puts doc if output == "debug"
    #----------------if direct(leaf) or search-----------------------------
    if doc.title =~ /意味/
      ja_list = leaf_parse doc
    else 
      ul_list  = doc.css "ul"
      ul_list.each do |cell|
        attributes = cell.attributes
        if attr_class = attributes["class"]
          if attr_class.value == "list-search-a"
            word_url = cell.css('li').css('a').first.attributes["href"]
            goo_word_url="#{goo_home}#{word_url}" #leaf page url
            begin
              html_leaf = open(goo_word_url,"User-Agent"=>userAgent).read
              doc = Nokogiri::HTML(html_leaf)
              ja_list =  leaf_parse doc
            rescue Exception =>e
              puts e
              ja_list.push e
            end
          end
        end
      end
    end
  rescue Exception =>e
    puts e
    ja_list.push e
  end

  list_cut_length ja_list, 50
end

def word_lem word
  word.downcase!
  lem = Lemmatizer.new
  word = lem.lemma(word)
end

def search_children ch
  word = ""
  unless ch.children
    word << ch.to_s
    word << '|'
  else
    ch.children.each do |chch|
      word << search_children(chch)
    end
  end
end 



if ARGV.length >0
  output = ARGV.length > 1 ? ARGV[1] : :one
  text = translate_goo_en_to_ja ARGV[0], output
else
  text = translate_en_to_jp "apple"
end
puts text





