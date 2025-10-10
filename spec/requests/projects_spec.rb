require 'rails_helper'

RSpec.describe "Projects", type: :request do
  admin = FactoryBot.create(:admin)
  manager = FactoryBot.create(:manager)
  contributor = FactoryBot.create(:contributor)
  project = FactoryBot.create(:project)

  describe "DELETE /projects/:id" do
    context "as an admin" do
      before { sign_in admin }
      it "deletes the project" do
        delete project_path(project)
        expect(response).to redirect_to(projects_path)
        expect(Project.exists?(project.id)).to be_falsey
      end
    end

    context "as a manager" do
      before { sign_in manager }
      it "deletes the project" do
        delete project_path(project)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
        expect(Project.exists?(project.id)).to be_truthy
      end
    end

    context "as a regular user" do
      before { sign_in contributor }
      it "does not delete the project and redirects with an error" do
        delete project_path(project)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
        expect(Project.exists?(project.id)).to be_truthy
      end
    end
  end


  describe "POST /projects" do
    # context "as an admin" do
    #   before { sign_in admin }
    #   it "creates the project" do
    #     create projects_path(project)
    #     expect(response).to redirect_to(project_path)
    #     expect(Project.exists?(project.id)).to be_truthy
    #   end
    # end

    # describe "POST /projects" do
    let(:project_params) { { project: { title: "Test Project", manager_id: manager.id, role: 'active' } } }

    context "as an admin" do
      before { sign_in admin }

      it "creates the project" do
        expect do
          post projects_path, params: project_params
        end.to change(Project, :count).by(1)

        expect(response).to redirect_to(project_path(Project.last))
        follow_redirect!
        # expect(response.body).to include("Project \"#{project.title}\" created successfully!")
      end
    end

    context "as an manager" do
      before { sign_in manager }

      it "creates the project" do
        expect do
          post projects_path, params: project_params
        end.to change(Project, :count).by(1)

        expect(response).to redirect_to(project_path(Project.last))
        follow_redirect!
        # expect(response.body).to include("Project was successfully created.")
      end
    end

    context "as an contributor" do
      before { sign_in contributor }

      it "creates the project" do
        expect do
          post projects_path, params: project_params
        end.to change(Project, :count).by(0)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        # expect(response.body).to include("Project was successfully created.")
      end
    end
  
  end
end