class AddInfoToConference < ActiveRecord::Migration
  def up
    add_column :conferences, :location_and_date, :string

    ab2010 = Conference.where(:year => 2010).first
    if ab2010
      ab2010.location_and_date = "Porto Alegre RS, 22-25 Jun/2010"
      ab2010.save!
    end

    ab2011 = Conference.where(:year => 2011).first
    if ab2011
      ab2011.location_and_date = "Fortaleza CE, 27/Jun - 1/Jul, 2011"
      ab2011.save!
    end
  end

  def down
    remove_column :conferences, :location_and_date
  end
end
