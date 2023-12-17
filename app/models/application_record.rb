# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def invalidate_cache(pattern)
    Rails.cache.delete_matched(pattern)
  end
end
