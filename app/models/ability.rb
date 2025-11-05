# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md

    user ||= User.new # guest

    if user.admin?
      can :manage, :all

    # elsif user.manager?
    #   can [:read, :create, :update, :destroy], Project, manager_id: user.id
    #   can [:read, :create, :update, :destroy], Task, :project => { :manager_id => user.id }
    #   can :assign, Task
    
    elsif user.manager?
      can [:read, :create, :update], Project, manager_id: user.id
      cannot :destroy, Project

      can [:read, :create, :update, :destroy], Task, project: { manager_id: user.id }
      can :assign, Task, project: { manager_id: user.id }
      can :update_status, Task, project: { manager_id: user.id }

      can :search_project, Project

    # elsif user.contributor?
    #   # can :manage, Task, contributor_id: user.id
    #   # can [:read, :update], Task, contributor_id: user.id
    #   can [:read, :show], Project
    #   can :manage, Task

    elsif user.contributor?
      can :read, Project, tasks: {contributor_id: user.id}
      
      can [:read, :update], Task, contributor_id: user.id
      cannot [:create, :destroy], Project
      cannot [:create, :destroy], Task
      can :update_status, Task, contributor_id: user.id
      # can :manage, all

      can :search_project, Project

    else
      can :read, Project, status: :active
    end
  end
end
