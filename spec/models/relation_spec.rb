require 'rails_helper'

RSpec.describe Relation, type: :model do
  context "Date" do
    it "is specific if no range data exists" do
      date = "2000-1-1"
      formatted_date = "01/01/2000"

      r = Relation.new(at: date)

      expect(r).to be_transient
      expect(r.at).to eq(formatted_date)
      expect(r.from).to eq(formatted_date)
      expect(r.to).to eq(formatted_date)
    end

    it "is not transient if different range data exists" do
      range_start = "2000-1-1"
      range_end = "2000-2-1"
      formatted_range_start = "01/01/2000"
      formatted_range_end = "01/02/2000"

      r = Relation.new(from: range_start, to: range_end)

      expect(r).not_to be_transient
      expect(r.at).to be_nil
      expect(r.from).to eq(formatted_range_start)
      expect(r.to).to eq(formatted_range_end)
    end

    it "is transient if equal range data exists" do
      date = "2000-1-1"
      formatted_date = "01/01/2000"

      r = Relation.new(from: date, to: date)

      expect(r).to be_transient
      expect(r.at).to eq(formatted_date)
      expect(r.from).to eq(formatted_date)
      expect(r.to).to eq(formatted_date)
    end

    context "with open ranges" do
      date = "2000-1-1"
      formatted_date = "01/01/2000"

      it "supports open 'from' ranges" do

        r = Relation.new(from: date)

        expect(r).not_to be_transient
        expect(r.at).to be_nil
        expect(r.from).to eq(formatted_date)
        expect(r.to).to be_nil
      end

      it "supports open 'to' ranges" do

        r = Relation.new(to: date)

        expect(r).not_to be_transient
        expect(r.at).to be_nil
        expect(r.from).to be_nil
        expect(r.to).to eq(formatted_date)
      end
    end

    context "with mixed data" do
      date = "1999-12-31"
      range_start = "2000-1-1"
      range_end = "2000-2-1"
      formatted_range_start = "01/01/2000"
      formatted_range_end = "01/02/2000"

      it "full range data takes precedence when included at the end" do

        r = Relation.new(at: date, from: range_start, to: range_end)

        expect(r).not_to be_transient
        expect(r.at).to be_nil
        expect(r.from).to eq(formatted_range_start)
        expect(r.to).to eq(formatted_range_end)
      end

      it "full range data takes precedence when included at the beginning" do

        r = Relation.new(from: range_start, to: range_end, at: date)

        expect(r).not_to be_transient
        expect(r.at).to be_nil
        expect(r.from).to eq(formatted_range_start)
        expect(r.to).to eq(formatted_range_end)
      end

      it "partial range data takes precedence when included at the end" do

        r = Relation.new(at: date, from: range_start)

        expect(r).not_to be_transient
        expect(r.at).to be_nil
        expect(r.from).to eq(formatted_range_start)
        expect(r.to).to be_nil

        r = Relation.new(at: date, to: range_end)

        expect(r).not_to be_transient
        expect(r.at).to be_nil
        expect(r.from).to be_nil
        expect(r.to).to eq(formatted_range_end)
      end

      it "partial range data takes precedence when included at the begining" do

        r = Relation.new(from: range_start, at: date)

        expect(r).not_to be_transient
        expect(r.at).to be_nil
        expect(r.from).to eq(formatted_range_start)
        expect(r.to).to be_nil

        r = Relation.new(to: range_end, at: date)

        expect(r).not_to be_transient
        expect(r.at).to be_nil
        expect(r.from).to be_nil
        expect(r.to).to eq(formatted_range_end)
      end
    end

    context "with invalid data" do
      invalid_date = "noop"
      date = "2000-1-1"
      formatted_date = "01/01/2000"

      it "ignores invalid only specific date values" do

        r = Relation.new(at: invalid_date)

        expect(r).to be_transient
        expect(r.at).to be_nil
        expect(r.from).to be_nil
        expect(r.to).to be_nil
      end

      it "ignores invalid only range date values" do

        r = Relation.new(from: invalid_date, to: invalid_date)

        expect(r).to be_transient
        expect(r.at).to be_nil
        expect(r.from).to be_nil
        expect(r.to).to be_nil
      end

      it "ignores invalid range date values when valid specific date value included at the end" do

        r = Relation.new(from: invalid_date, to: invalid_date, at: date)

        expect(r).to be_transient
        expect(r.at).to eq(formatted_date)
        expect(r.from).to eq(formatted_date)
        expect(r.to).to eq(formatted_date)
      end

      it "ignores invalid range date values when valid specific date value included at the beginning" do

        r = Relation.new(at: date, from: invalid_date, to: invalid_date)

        expect(r).to be_transient
        expect(r.at).to eq(formatted_date)
        expect(r.from).to eq(formatted_date)
        expect(r.to).to eq(formatted_date)
      end
    end

    context "with blank values" do
      date = "2000-1-1"
      formatted_date = "01/01/2000"

      def blank_value
        [nil, ""].shuffle.first
      end

      context "when the object has been persisted" do
        it "clears the values" do

          r = Relation.create(at: date)
          r.from = blank_value

          expect(r).not_to be_transient
          expect(r.at).to be_nil
          expect(r.from).to be_nil
          expect(r.to).to eq(formatted_date)

          r = Relation.create(at: date)
          r.to = blank_value

          expect(r).not_to be_transient
          expect(r.at).to be_nil
          expect(r.from).to eq(formatted_date)
          expect(r.to).to be_nil

          r = Relation.create(from: date)
          r.at = blank_value

          expect(r).to be_transient
          expect(r.at).to be_nil
          expect(r.from).to be_nil
          expect(r.to).to be_nil
        end
      end

      context "when the object has not been persisted" do
        it "ignores the values" do

          r = Relation.new(at: date, from: blank_value, to: blank_value)

          expect(r).to be_transient
          expect(r.at).to eq(formatted_date)
          expect(r.from).to eq(formatted_date)
          expect(r.to).to eq(formatted_date)

          r = Relation.new(at: blank_value, from: date, to: blank_value)

          expect(r).not_to be_transient
          expect(r.at).to be_nil
          expect(r.from).to eq(formatted_date)
          expect(r.to).to be_nil

          r = Relation.new( at: blank_value, from: blank_value, to: date)

          expect(r).not_to be_transient
          expect(r.at).to be_nil
          expect(r.from).to be_nil
          expect(r.to).to eq(formatted_date)
        end
      end
    end
  end
end
