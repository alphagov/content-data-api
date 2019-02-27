class AddSatisfactionFunction < ActiveRecord::Migration[5.2]
  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION calculate_satisfaction (useful_yes NUMERIC, useful_no NUMERIC)
      RETURNS float AS $$
        BEGIN
          CASE
            WHEN useful_yes + useful_no = 0 THEN RETURN NULL;
            ELSE RETURN useful_yes / (useful_yes + useful_no)::float;
          END CASE;
        END;
      $$
      LANGUAGE 'plpgsql'
      IMMUTABLE
      LEAKPROOF
      PARALLEL SAFE
      RETURNS NULL ON NULL INPUT;
    SQL
  end

  def down
    execute <<~SQL
      DROP FUNCTION IF EXISTS calculate_satisfaction(useful_yes NUMERIC, useful_no NUMERIC);
    SQL
  end
end
