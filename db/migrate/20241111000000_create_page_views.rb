class CreatePageViews < ActiveRecord::Migration[8.0]
  def change
    create_table :page_views do |t|
      t.string :url, null: false
      t.string :referrer
      t.datetime :viewed_at, null: false
      t.timestamps
    end

    add_index :page_views, :url
    add_index :page_views, :viewed_at

    # Adding 'hash_value' column
    add_column :page_views, :hash_value, :string

    # Use Rails callbacks for setting the 'hash_value' value
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE FUNCTION update_page_view_hash_value() 
          RETURNS trigger AS $$
          BEGIN
            NEW.hash_value = MD5(NEW.id || NEW.url || COALESCE(NEW.referrer, '') || NEW.viewed_at::text);
            RETURN NEW;
          END;
          $$ LANGUAGE plpgsql;

          CREATE TRIGGER before_insert_page_view
          BEFORE INSERT ON page_views
          FOR EACH ROW EXECUTE FUNCTION update_page_view_hash_value();
        SQL
      end
    end
  end
end
