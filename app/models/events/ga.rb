class Events::GA < ApplicationRecord
  enum process_name: { user_feedback: 0, views: 1, searches: 2 }
end
