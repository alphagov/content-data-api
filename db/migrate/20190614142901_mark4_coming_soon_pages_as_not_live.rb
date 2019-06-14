class Mark4ComingSoonPagesAsNotLive < ActiveRecord::Migration[5.2]
  CONTENT_IDS = %w[
    33a6001a-8947-477e-93e9-9134587801ae
    81ebd48d-733c-4d54-8bc3-572abf6d02a5
    9a8844b3-c4b8-4723-aecb-5d27b5cdfc88
    9bc3c55b-1d0d-4c7c-92b4-0b56ff560ee3
  ]

  def up
    Dimensions::Edition
      .where(content_id: CONTENT_IDS)
      .update(live: false)
  end

  def down
    Dimensions::Edition
      .where(content_id: CONTENT_IDS)
      .update(live: true)
  end
end
