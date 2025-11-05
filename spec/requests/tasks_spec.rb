require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let(:manager) { FactoryBot.create(:manager) }
  let(:contributor) { FactoryBot.create(:contributor) }
  let(:other_contributor) { FactoryBot.create(:contributor) }
  let(:admin) { FactoryBot.create(:admin) }
  let(:project) { FactoryBot.create(:project, manager_id: manager.id) }
  let!(:task) { FactoryBot.create(:task, project: project, contributor_id: contributor.id, status: 'not_started') }

  describe "GET /projects/:project_id/tasks/:id" do
    context "as assigned contributor" do
      before { sign_in contributor }

      it "allows contributor assigned to task to view" do
        get project_task_path(project, task)
        expect(response).to have_http_status(:ok)
      end
    end

    context "as unassigned contributor" do
      before { sign_in other_contributor }

      it "does not allow unassigned contributor to view" do
        get project_task_path(project, task)
        expect(response).to have_http_status(:forbidden).or redirect_to(root_path)
      end
    end

    context "as manager" do
      before { sign_in manager }

      it "allows manager to view" do
        get project_task_path(project, task)
        expect(response).to have_http_status(:ok)
      end
    end

    context "as admin" do
      before { sign_in admin }

      it "allows admin to view" do
        get project_task_path(project, task)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /projects/:project_id/tasks/:id/edit" do
    context "as assigned contributor" do
      before { sign_in contributor }

      it "allows assigned contributor to edit" do
        get edit_project_task_path(project, task)
        expect(response).to have_http_status(:ok)
      end
    end

    context "as unassigned contributor" do
      before { sign_in other_contributor }

      it "does not allow unassigned contributor to edit" do
        get edit_project_task_path(project, task)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end

    context "as manager" do
      before { sign_in manager }

      it "allows manager to edit" do
        get edit_project_task_path(project, task)
        expect(response).to have_http_status(:ok)
      end
    end

    context "as admin" do
      before { sign_in admin }

      it "allows admin to edit" do
        get edit_project_task_path(project, task)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /projects/:project_id/tasks/:id" do
    context "as assigned contributor" do
      before { sign_in contributor }

      it "updates task status successfully" do
        patch project_task_path(project, task), params: { task: { status: 'in_progress' } }
        expect(response).to redirect_to(project_task_path(project, task))
        expect(flash[:notice]).to eq("Task \"#{task.title}\" Updated Successfully!")
        expect(task.reload.status).to eq('in_progress')
      end
    end

    context "as manager" do
      before { sign_in manager }

      it "updates task details successfully" do
        patch project_task_path(project, task), params: { task: { title: 'Updated Title' } }
        expect(response).to redirect_to(project_task_path(project, task))
        expect(flash[:notice]).to eq("Task \"#{task.reload.title}\" Updated Successfully!")
      end
    end

    context "as other contributor" do
      before { sign_in other_contributor }

      it "does not allow update" do
        patch project_task_path(project, task), params: { task: { status: 'completed' } }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end
  end

  describe "DELETE /projects/:project_id/tasks/:id" do
    context "as manager" do
      before { sign_in manager }

      it "deletes the task" do
        expect {
          delete project_task_path(project, task)
        }.to change(Task, :count).by(-1)
        expect(response).to redirect_to(project_tasks_path(project))
        expect(flash[:alert]).to eq("Task \"#{task.title}\" Deleted Successfully!")
      end
    end

    context "as assigned contributor" do
      before { sign_in contributor }

      it "does not allow deletion" do
        expect {
          delete project_task_path(project, task)
        }.not_to change(Task, :count)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end

    context "as other contributor" do
      before { sign_in other_contributor }

      it "does not allow deletion" do
        expect {
          delete project_task_path(project, task)
        }.not_to change(Task, :count)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end

    context "as admin" do
      before { sign_in admin }

      it "deletes the task" do
        expect {
          delete project_task_path(project, task)
        }.to change(Task, :count).by(-1)
        expect(response).to redirect_to(project_tasks_path(project))
        expect(flash[:alert]).to eq("Task \"#{task.title}\" Deleted Successfully!")
      end
    end
  end
end