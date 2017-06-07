class Resume < ApplicationRecord

  include DefaultSortingConcern
  include FulltextConcern
  include CaptionConcern

  cattr_accessor :fulltext_fields do
    []
  end

  def self.permitted_attributes
    return :name,:technology,:degree,:tenth_percentage,:plus_two_percentage,:graduation_percentage,:pg_percentage,:projects,:phone,:email
  end
end
