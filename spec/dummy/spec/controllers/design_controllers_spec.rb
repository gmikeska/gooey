require 'rails_helper'

# Change this ArticlesController to your project
RSpec.describe Gooey::DesignsController, type: :controller do

    let(:valid_attributes) {
      {name:"simpleDiv",fields:{text:{required:true, default:"Hello World!"}}, content_template:"{text}", tag:"div"}
    }

    let(:valid_session) { {} }

    describe "GET #index" do
        it "returns a success response" do
            Gooey::Design.create! valid_attributes
            get :index, params: {}, session: valid_session
            expect(response).to be_successful # be_successful expects a HTTP Status code of 200
            # expect(response).to have_http_status(302) # Expects a HTTP Status code of 302
        end
    end
end
