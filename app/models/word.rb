class Word < ActiveRecord::Base
  belongs_to :text



  def to_hide
     true
  end


end
