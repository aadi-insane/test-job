require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let(:admin) { FactoryBot.create(:admin) }
  let(:manager) { FactoryBot.create(:manager) }
  let(:contributor) { FactoryBot.create(:contributor) }
  let(:project) { FactoryBot.create(:project) }

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

      it "does not delete the project and redirects with an error" do
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
    # let(:task_params) { { task: { title: "Test Task", manager_id: manager.id, status: 'not_started', project_id: project.id } } }
    
    let(:project_params) { { project: { title: "Test Project", manager_id: manager.id, status: 'active' } } }

    context "as an admin" do
      before { sign_in admin }

      it "creates the project" do
        expect do
          post projects_path, params: project_params
        end.to change(Project, :count).by(1)

        expect(response).to redirect_to(project_path(Project.last))
        follow_redirect!
      end

      it "creates a task for the project" do
        task_params = {
          task: {
            title: "Test Task",
            due_date: Date.today,
            status: 'not_started',
            project_id: project.id,
            contributor_id: contributor.id
          }
        }

        expect do
          post project_tasks_path(project), params: task_params
        end.to change(Task, :count).by(1)

        new_task = Task.last
        expect(response).to redirect_to(project_task_path(project, new_task))
        follow_redirect!
      end

      it "prevents reassigning a task to a contributor already assigned to the project" do
        new_project = FactoryBot.create(:project, manager_id: manager.id)
        task_params = {
          task: {
            title: "Test Task",
            due_date: Date.today,
            status: 'not_started',
            project_id: new_project.id,
            contributor_id: contributor.id
          }
        }

        expect do
          post project_tasks_path(new_project), params: task_params
        end.to change(Task, :count).by(1)

        new_task = Task.last
        expect(response).to redirect_to(project_task_path(new_project, new_task))
        follow_redirect!

        expect do
          post project_tasks_path(new_project), params: task_params
        end.not_to change(Task, :count)

        expect(flash[:alert]).to eq("This Contributor is already assigned to this Project can't assign again!")
      end
    end

    context "as a manager" do
      before { sign_in manager }

      it "creates the project" do
        expect do
          post projects_path, params: project_params
        end.to change(Project, :count).by(1)

        expect(response).to redirect_to(project_path(Project.last))
        follow_redirect!
      end

      it "creates a task for the project" do
        new_project = FactoryBot.create(:project, manager_id: manager.id)
        task_params = {
          task: {
            title: "Test Task",
            due_date: Date.today,
            status: 'not_started',
            project_id: new_project.id,
            contributor_id: contributor.id
          }
        }

        expect do
          post project_tasks_path(new_project), params: task_params
        end.to change(Task, :count).by(1)

        new_task = Task.last
        expect(response).to redirect_to(project_task_path(new_project, new_task))
        follow_redirect!
      end

      it "prevents reassigning a task to a contributor already assigned to the project" do
        new_project = FactoryBot.create(:project, manager_id: manager.id)
        task_params = {
          task: {
            title: "Test Task",
            due_date: Date.today,
            status: 'not_started',
            project_id: new_project.id,
            contributor_id: contributor.id
          }
        }

        expect do
          post project_tasks_path(new_project), params: task_params
        end.to change(Task, :count).by(1)

        new_task = Task.last
        expect(response).to redirect_to(project_task_path(new_project, new_task))
        follow_redirect!

        expect do
          post project_tasks_path(new_project), params: task_params
        end.not_to change(Task, :count)

        
      end
    end

    context "as a contributor" do
      before { sign_in contributor }

      it "does not create the project and redirects to root" do
        expect do
          post projects_path, params: project_params
        end.not_to change(Project, :count)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
        follow_redirect!
      end
    end
  end

  describe "GET /projects" do
    let!(:manager_1) { FactoryBot.create(:manager) }
    let!(:manager_2) { FactoryBot.create(:manager) }

    let!(:active_project_1) { FactoryBot.create(:project, title: "Active Project 1", status: "active", manager: manager_1) }
    let!(:active_project_2) { FactoryBot.create(:project, title: "Active Project 2", status: "active", manager: manager_2) }
    let!(:completed_project) { FactoryBot.create(:project, title: "Completed Project", status: "completed", manager: manager_1) }

    context "as an admin" do
      before { sign_in admin }

      it "lists all projects without filters" do
        get projects_path
        expect(response).to have_http_status(:success)

        # check content or count
        expect(response.body).to include("Active Project 1", "Active Project 2", "Completed Project")
      end

      it "filters projects by status" do
        get projects_path, params: { status: "active" }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Active Project 1", "Active Project 2")
        expect(response.body).not_to include("Completed Project")
      end

      it "filters projects by manager_id" do
        get projects_path, params: { manager_id: manager_1.id }
        expect(response.body).to include("Active Project 1", "Completed Project")
        expect(response.body).not_to include("Active Project 2")
      end

      it "filters projects by both status and manager_id" do
        get projects_path, params: { status: "active", manager_id: manager_1.id }
        expect(response.body).to include("Active Project 1")
        expect(response.body).not_to include("Active Project 2", "Completed Project")
      end
    end

    context "as a manager" do
      before { sign_in manager_1 }

      it "lists only their own projects" do
        get projects_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Active Project 1", "Completed Project")
        expect(response.body).not_to include("Active Project 2")
      end

      it "filters their own projects by status" do
        get projects_path, params: { status: "active" }
        expect(response.body).to include("Active Project 1")
        expect(response.body).not_to include("Completed Project", "Active Project 2")
      end
    end
  end

end
