class EnablePgTrgmExtension < ActiveRecord::Migration
  def up
    enable_extension 'pg_trgm'
  end

  def down
    disable_extension 'pg_trgm'
  end
end

