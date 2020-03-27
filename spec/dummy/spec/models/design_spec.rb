require 'rails_helper'

RSpec.describe Gooey::Design, :type => :model do
  subject {
         described_class.new(name:"simpleDiv",
                             fields:{text:{required:true, default:"Hello World!"}},
                              content_template:"{text}",
                              tag:"div"
         )
  }
  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end
  it "is not valid with missing fields" do
    subject.content_template = "{text} {name}"
    expect(subject).to_not be_valid
  end

end
