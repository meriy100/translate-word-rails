require_relative  "translate"
require_relative "parsing_doc"
require "lemmatizer"


class WordsController < ApplicationController
  before_action :set_word, only: [:show, :edit, :update, :destroy]

  # GET /words
  # GET /words.json
  def index
    @words = Word.order "updated_at DESC"
    @text = Text.last
  end

  def search
    @searched = params[:search_word]
    @words = Word.where(en: @searched)
    @text = Text.last
  end


  # GET /words/1
  # GET /words/1.json
  def show
  end

  # GET /words/new
  def new
    @word = Word.new
  end

  # GET /words/1/edit
  def edit
  end
  def hide
    logger.debug "to_hide"
    @word = Word.find params[:id]
    @word.update ({hide:  true})
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  # POST /words
  # POST /words.json
  def create
    text = Text.new entext: params[:text]
    text.save
    line = parsing params[:text]
     line_translate line, text
    respond_to do |format|
      format.html { redirect_to :back }
    end

  end

  # PATCH/PUT /words/1
  # PATCH/PUT /words/1.json
  def update
    respond_to do |format|
      if @word.update(word_params)
        format.html { redirect_to @word, notice: 'Word was successfully updated.' }
        format.json { render :show, status: :ok, location: @word }
      else
        format.html { render :edit }
        format.json { render json: @word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /words/1
  # DELETE /words/1.json
  def destroy
    @word.destroy
    respond_to do |format|
      format.html { redirect_to words_url, notice: 'Word was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def view
    word = params[:id].downcase
    lem = Lemmatizer.new
    word = lem.lemma(word)
    @searched = Word.where(en: word).first

    @jsearched = {'en' => @searched.en, 'ja' => @searched.ja }
    render :json => @jsearched
    p '----------------------------------'
    p params[:id]
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_word
      @word = Word.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def word_params
      params.require(:word).permit(:en, :ja, :count, :hide, :text_id)
    end


    def line_translate line, text
      line.each do |word|
        word.downcase!
        lem = Lemmatizer.new
        word = lem.lemma(word)
        unless @data =  Word.find_by(en: word)
          ja_word = translate_goo_en_to_ja word
          #sleep 0.25
          # Word.create en: word, ja: ja_word, count: 1
          w = Word.new en: word, ja: ja_word, hide: false, count: 1, text_id: text.id 
          w.save
        else
          @data.update( {count: @data.count + 1 })
        end
      end
    end
end
