# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

miles = Node.create!( name: 'Miles Davis',
                          description: '', 
                          node_type: 'trumpet')

bill = Node.create!( name: 'Bill Evans', 
                          description: '', 
                          node_type: 'piano')

herbie = Node.create!( name: 'Herbie Hancock', 
                          description: '', 
                          node_type: 'piano')

red = Node.create!( name: 'Red Garland', 
                          description: '', 
                          node_type: 'piano')

trane = Node.create!( name: 'John Coltrane', 
                          description: '', 
                          node_type: 'tenor sax')

wayne = Node.create!( name: 'Wayne Shorter', 
                          description: '', 
                          node_type: 'tenor sax')

kenny = Node.create!( name: 'Kenny Garret', 
                          description: '', 
                          node_type: 'alto sax')

ron = Node.create!( name: 'Ron Carter', 
                          description: '', 
                          node_type: 'bass')

paul = Node.create!( name: 'Paul Chambers', 
                          description: '', 
                          node_type: 'bass')

dave = Node.create!( name: 'Dave Holland', 
                          description: '', 
                          node_type: 'bass')

jimmy = Node.create!( name: 'Jimmy Cobb', 
                          description: '', 
                          node_type: 'drums')

tony = Node.create!( name: 'Tony Williams', 
                          description: '', 
                          node_type: 'drums')

jack = Node.create!( name: 'Jack de Johnette', 
                          description: '', 
                          node_type: 'drums')

Relation.create!(source: miles,
                target: bill,
                relation_type: 'music')

Relation.create!(source: miles,
                target: herbie,
                relation_type: 'music')

Relation.create!(source: miles,
                target: red,
                relation_type: 'music')

Relation.create!(source: miles,
                target: trane,
                relation_type: 'music')

Relation.create!(source: miles,
                target: wayne,
                relation_type: 'music')

Relation.create!(source: miles,
                target: kenny,
                relation_type: 'music')

Relation.create!(source: miles,
                target: ron,
                relation_type: 'music')

Relation.create!(source: miles,
                target: paul,
                relation_type: 'music')

Relation.create!(source: miles,
                target: dave,
                relation_type: 'music')

Relation.create!(source: miles,
                target: jimmy,
                relation_type: 'music')

Relation.create!(source: miles,
                target: tony,
                relation_type: 'music')

Relation.create!(source: miles,
                target: jack,
                relation_type: 'music')

