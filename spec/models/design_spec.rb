require 'rails_helper'

RSpec.describe Gooey::Design, :type => :model do
  it "is valid with valid attributes" do
    expect(Gooey::Design.new).to be_valid
  end
  it "is not valid with missing fields" do
    f = {text:{required:true, default:"Hello World!"}}
    design = Gooey::Design.new(name:"simpleDiv",fields:f, content_template:"{text} {name}", tag:"div")
    expect(design).to_not be_valid
  end

  it "is not valid without a description"
  it "is not valid without a start_date"
  it "is not valid without a end_date"
end
