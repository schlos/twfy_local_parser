require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  def setup
    @dataset = Factory(:dataset)
  end
  
  # index test
  context "on GET to :index" do
    context "with basic request" do
      setup do
        get :index
      end

      should_assign_to(:datasets) { Dataset.find(:all)}
      should_respond_with :success
      should_render_template :index
      should_respond_with_content_type 'text/html'
      should "list datasets" do
        assert_select "li a", @dataset.title
      end
      
      should "have title" do
        assert_select "title", /Datasets/
      end
    end
        
    context "with xml requested" do
      setup do
        get :index, :format => "xml"
      end
  
      should_assign_to(:datasets) { Dataset.find(:all)}
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/xml'
    end

    context "with json requested" do
      setup do
        get :index, :format => "json"
      end
  
      should_assign_to(:datasets) { Dataset.find(:all)}
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/json'
    end
    
  end  

  # show test
  context "on GET to :show" do
    context "with basic request" do
      setup do
        get :show, :id => @dataset.id
      end

      should_assign_to(:dataset) { @dataset }
      should_respond_with :success
      should_render_template :show
      should_respond_with_content_type 'text/html'

      should "show title" do
        assert_select "title", /#{@dataset.title}/
      end
    end
    
    context "with xml requested" do
      setup do
        get :show, :id => @dataset.id, :format => "xml"
      end
  
      should_assign_to(:dataset) { @dataset }
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/xml'
    end

    context "with json requested" do
      setup do
        get :show, :id => @dataset.id, :format => "json"
      end
  
      should_assign_to(:dataset) {  @dataset }
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/json'
    end
        
  end  
  
  # new test
  context "on GET to :new without auth" do
    setup do
      get :new
    end
  
    should_respond_with 401
  end

  context "on GET to :new" do
    setup do
      stub_authentication
      get :new
    end
  
    should_assign_to(:dataset)
    should_respond_with :success
    should_render_template :new
  
    should "show form" do
      assert_select "form#new_dataset"
    end
  end  
  
  # create test
   context "on POST to :create" do
    
     context "without auth" do
       setup do
         post :create, :dataset => Factory.attributes_for(:dataset)
       end

       should_respond_with 401
     end

     context "with valid params" do
       setup do
         stub_authentication
         post :create, :dataset => Factory.attributes_for(:dataset, :key => "foo123")
       end
     
       should_change "Dataset.count", :by => 1
       should_assign_to :dataset
       should_redirect_to( "the show page for dataset") { dataset_url(assigns(:dataset)) }
       should_set_the_flash_to "Successfully created dataset"
     
     end
     
     context "with invalid params" do
       setup do
         stub_authentication
         post :create, :dataset => {:title => "Dataset title"}
       end
     
       should_not_change "Dataset.count"
       should_assign_to :dataset
       should_render_template :new
       should_not_set_the_flash
     end
  
   end  
  
   # edit test
   context "on GET to :edit without auth" do
     setup do
       get :edit, :id => @dataset
     end

     should_respond_with 401
   end

   context "on GET to :edit with existing record" do
     setup do
       stub_authentication
       get :edit, :id => @dataset
     end
  
     should_assign_to(:dataset)
     should_respond_with :success
     should_render_template :edit
  
     should "show form" do
       assert_select "form#edit_dataset_#{@dataset.id}"
     end
   end  
  
  # update test
  context "on PUT to :update" do
    context "without auth" do
      setup do
        put :update, :id => @dataset.id, :dataset => { :title => "New title" }
      end

      should_respond_with 401
    end
    
    context "with valid params" do
      setup do
        stub_authentication
        put :update, :id => @dataset.id, :dataset => { :title => "New title" }
      end
    
      should_not_change "Dataset.count"
      should_change "@dataset.reload.title", :to => "New title"
      should_assign_to :dataset
      should_redirect_to( "the show page for dataset") { dataset_path(assigns(:dataset)) }
      should_set_the_flash_to "Successfully updated dataset"
    
    end
    
    context "with invalid params" do
      setup do
        stub_authentication
        put :update, :id => @dataset.id, :dataset => {:title => ""}
      end
    
      should_not_change "Dataset.count"
      should_not_change "@dataset.reload.title"
      should_assign_to :dataset
      should_render_template :edit
      should_not_set_the_flash
    end
  end  
  
  # data tests
  context "on GET to data with dataset and council" do
    setup do
      @council = Factory(:council)
      @datapoint = Factory(:datapoint, :data => [["LOCAL AUTHORITY", "% who are foo"], ["Some City ", "37"]], :council => @council, :dataset_id => @dataset.id)
      get :data, :id => @dataset.id, :council_id => @council.id
    end

    should_assign_to(:dataset) { @dataset }
    should_assign_to(:council) { @council }
    should_respond_with :success
    should_render_template :data

    should "show dataset in title" do
      assert_select "title", /#{@dataset.title}/
    end
    
    should "show council in title" do
      assert_select "title", /#{@council.title}/
    end
    
    should "show datapoint data in table" do
      assert_select "#dataset_data table th", 2 do
        assert_select "th", "% who are foo"
      end
      assert_select "#dataset_data table td", "37"
    end
    
  end
  
  context "on GET to data with no datapoint for dataset and council" do
    setup do
      @council = Factory(:council)
      get :data, :id => @dataset.id, :council_id => @council.id
    end

    should_assign_to(:dataset) { @dataset }
    should_assign_to(:council) { @council }
    should_respond_with :success
    should_render_template :data

    should "show dataset in title" do
      assert_select "title", /#{@dataset.title}/
    end
    
    should "show message" do
      assert_select "p.alert", /no data/
    end
    
  end
  
end
