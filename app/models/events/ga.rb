class Events::GA < ApplicationRecord
  enum process_name: { user_feedback: 0, views: 1, number_of_internal_searches: 2 }
end
