# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

### Users

admin = User.create!(name: 'Admin', 
                    email: 'admin@onodo.org', 
                    password: 'password', 
                    password_confirmation: 'password')

user = User.create!( name: 'A user', 
                    email: 'user@example.com', 
                    password: 'password', 
                    password_confirmation: 'password')

### Miles Davis Relations

milesViz = Visualization.create!( name: 'Miles Davis Relations', author_id: admin.id)
milesDB = Dataset.create!( visualization: milesViz )

miles = Node.create!( name: 'Miles Davis',
                          description: '', 
                          node_type: 'trumpet',
                          dataset: milesDB)

bill = Node.create!( name: 'Bill Evans', 
                          description: '', 
                          node_type: 'piano',
                          dataset: milesDB)

herbie = Node.create!( name: 'Herbie Hancock', 
                          description: '', 
                          node_type: 'piano',
                          dataset: milesDB)

red = Node.create!( name: 'Red Garland', 
                          description: '', 
                          node_type: 'piano',
                          dataset: milesDB)

trane = Node.create!( name: 'John Coltrane', 
                          description: '', 
                          node_type: 'tenor sax',
                          dataset: milesDB)

add = Node.create!( name: 'Cannonball Adderley', 
                          description: '', 
                          node_type: 'alto sax',
                          dataset: milesDB)

wayne = Node.create!( name: 'Wayne Shorter', 
                          description: '', 
                          node_type: 'tenor sax',
                          dataset: milesDB)

kenny = Node.create!( name: 'Kenny Garret', 
                          description: '', 
                          node_type: 'alto sax',
                          dataset: milesDB)

ron = Node.create!( name: 'Ron Carter', 
                          description: '', 
                          node_type: 'bass',
                          dataset: milesDB)

paul = Node.create!( name: 'Paul Chambers', 
                          description: '', 
                          node_type: 'bass',
                          dataset: milesDB)

dave = Node.create!( name: 'Dave Holland', 
                          description: '', 
                          node_type: 'bass',
                          dataset: milesDB)

jimmy = Node.create!( name: 'Jimmy Cobb', 
                          description: '', 
                          node_type: 'drums',
                          dataset: milesDB)

tony = Node.create!( name: 'Tony Williams', 
                          description: '', 
                          node_type: 'drums',
                          dataset: milesDB)

jack = Node.create!( name: 'Jack de Johnette', 
                          description: '', 
                          node_type: 'drums',
                          dataset: milesDB)

Relation.create!(source: miles,
                target: bill,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: herbie,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: red,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: add,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: trane,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: wayne,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: kenny,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: ron,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: paul,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: dave,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: jimmy,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: tony,
                relation_type: 'music',
                dataset: milesDB)

Relation.create!(source: miles,
                target: jack,
                relation_type: 'music',
                dataset: milesDB)


### The Godfather Characters

godfatherViz = Visualization.create!( 
                  name: 'The Godfather Characters',
                  description: "A list of characters from 1972 film The Godfather, directed by Francis Ford Coppola & produced by Albert S. Ruddy from a screenplay by Mario Puzo and Coppola.",
                  author_id: admin.id)
godfatherDB = Dataset.create!( visualization: godfatherViz )


Node.create!( name: 'Anthony Corleone', 
              description: '', 
              node_type: 'Corleone',
              dataset: godfatherDB)

Node.create!( name: 'Carmella Corleone', 
              description: '', 
              node_type: 'Corleone',
              dataset: godfatherDB)

Node.create!( name: 'Connie Corleone', 
              description: '', 
              node_type: 'Corleone',
              dataset: godfatherDB)

Node.create!( name: 'Sonny Corleone', 
              description: '', 
              node_type: 'Corleone',
              dataset: godfatherDB)

Node.create!( name: 'Michael Corleone', 
              description: '', 
              node_type: 'Corleone',
              dataset: godfatherDB)

Node.create!( name: 'Fredo Corleone', 
              description: '', 
              node_type: 'Corleone',
              dataset: godfatherDB)


### Miles Davis Story

milesStory = Story.create!( name: 'The Miles Davis Story', 
              visualization: milesViz,
              author_id: admin.id)
