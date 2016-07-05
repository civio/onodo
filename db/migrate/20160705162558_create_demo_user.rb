class CreateDemoUser < ActiveRecord::Migration
  def up
    random_password = random_string
    User.create!( name: 'demo',
                  email: 'demo@onodo.org',
                  password: random_password,
                  password_confirmation: random_password,
                  confirmed_at: DateTime.now )
  end

  def down
    User.find_by( name: 'demo' ).destroy
  end

  private

  def random_string
    [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
  end
end
