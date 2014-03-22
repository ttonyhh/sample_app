require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { "Welcome to Fazio's Last Hurrah" }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    describe "for signed_in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        35.times { FactoryGirl.create(:micropost, user: user) }
        sign_in user
        visit root_path
      end

      after { user.microposts.delete_all }

      it "should render the user's feed" do
        user.feed.paginate(page: 1).each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end

      it "should have micropost count and pluralize" do
        page.should have_content('35 microposts')
      end

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end
    end
  end

  describe "Help page" do
    before { visit help_path }

    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)    { 'About Us' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
  	before { visit contact_path }
    let(:heading)    { 'Contact Us' }
    let(:page_title) { 'Contact Us' }

    it_should_behave_like "all static pages"
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact Us'))
    click_link "Home"
    click_link "Sign up now"
    expect(page).to have_title(full_title('Sign up'))
    click_link "Fazio's Last Hurrah"
    expect(page).to have_title(full_title(''))
  end
end

