Rails.application.routes.draw do
  require 'subdomain'
  constraints UserSubdomain do
    devise_for :users, controllers: { registrations: 'users/registrations',
                                      sessions: 'users/sessions',
                                      invitations: 'users/invitations',
                                      confirmations: 'users/confirmations' }

    root 'projects#index'

    # Save sample table state
    post '/state_save/:team_id/:user_id',
         to: 'user_samples#save_samples_table_status',
         as: 'save_samples_table_status',
         defaults: { format: 'json' }

    post '/state_load/:team_id/:user_id',
         to: 'user_samples#load_samples_table_status',
         as: 'load_samples_table_status',
         defaults: { format: 'json' }

    resources :activities, only: [:index]

    get 'forbidden', to: 'application#forbidden', as: 'forbidden'
    get 'not_found', to: 'application#not_found', as: 'not_found'

    # Settings
    get 'users/settings/account/preferences',
        to: 'users/settings/account/preferences#index',
        as: 'preferences'
    get 'users/settings/account/addons',
        to: 'users/settings/account/addons#index',
        as: 'addons'
    put 'users/settings/account/preferences',
        to: 'users/settings/account/preferences#update',
        as: 'update_preferences'
    get 'users/settings/account/preferences/tutorial',
        to: 'users/settings/account/preferences#tutorial',
        as: 'tutorial'
    post 'users/settings/account/preferences/reset_tutorial/',
         to: 'users/settings/account/preferences#reset_tutorial',
         as: 'reset_tutorial'
    post 'users/settings/account/preferences/notifications_settings',
         to: 'users/settings/account/preferences#notifications_settings',
         as: 'notifications_settings',
         defaults: { format: 'json' }

    # Change user's current team
    post 'users/settings/user_current_team',
         to: 'users/settings#user_current_team',
         as: 'user_current_team'

    get 'users/settings/teams',
        to: 'users/settings/teams#index',
        as: 'teams'
    post 'users/settings/teams/datatable',
         to: 'users/settings/teams#datatable',
         as: 'teams_datatable'
    get 'users/settings/teams/new',
        to: 'users/settings/teams#new',
        as: 'new_team'
    post 'users/settings/teams',
         to: 'users/settings/teams#create',
         as: 'create_team'
    get 'users/settings/teams/:id',
        to: 'users/settings/teams#show',
        as: 'team'
    post 'users/settings/teams/:id/users_datatable',
         to: 'users/settings/teams#users_datatable',
         as: 'team_users_datatable'
    get 'users/settings/teams/:id/name_html',
        to: 'users/settings/teams#name_html',
        as: 'team_name'
    get 'users/settings/teams/:id/description_html',
        to: 'users/settings/teams#description_html',
        as: 'team_description'
    put 'users/settings/teams/:id',
        to: 'users/settings/teams#update',
        as: 'update_team'
    delete 'users/settings/teams/:id',
           to: 'users/settings/teams#destroy',
           as: 'destroy_team'

    put 'users/settings/user_teams/:id',
        to: 'users/settings/user_teams#update',
        as: 'update_user_team'
    get 'users/settings/user_teams/:id/leave_html',
        to: 'users/settings/user_teams#leave_html',
        as: 'leave_user_team_html'
    get 'users/settings/user_teams/:id/destroy_html',
        to: 'users/settings/user_teams#destroy_html',
        as: 'destroy_user_team_html'
    delete 'users/settings/user_teams/:id',
           to: 'users/settings/user_teams#destroy',
           as: 'destroy_user_team'

    # Invite users
    devise_scope :user do
      post '/invite',
           to: 'users/invitations#invite_users',
           as: 'invite_users'
    end

    # Notifications
    get 'users/:id/recent_notifications',
        to: 'user_notifications#recent_notifications',
        as: 'recent_notifications',
        defaults: { format: 'json' }

    get 'users/:id/unseen_notification',
        to: 'user_notifications#unseen_notification',
        as: 'unseen_notification',
        defaults: { format: 'json' }

    get 'users/notifications',
        to: 'user_notifications#index',
        as: 'notifications'

    # Get Zip Export
    get 'zip_exports/download/:id',
        to: 'zip_exports#download',
        as: 'zip_exports_download'

    get 'zip_exports/file_expired',
        to: 'zip_exports#file_expired',
        as: 'file_expired'

    resources :teams do
      resources :repositories, only: %i(index create destroy update) do
        collection do
          get 'create_modal', to: 'repositories#create_modal',
              defaults: { format: 'json' }
        end
        get 'show_tab', to: 'repositories#show_tab',
            defaults: { format: 'json' }
        get 'destroy_modal', to: 'repositories#destroy_modal',
            defaults: { format: 'json' }
        get 'rename_modal', to: 'repositories#rename_modal',
            defaults: { format: 'json' }
        get 'copy_modal', to: 'repositories#copy_modal',
            defaults: { format: 'json' }
        post 'copy', to: 'repositories#copy',
             defaults: { format: 'json' }
      end
      resources :samples, only: [:new, :create]
      resources :sample_types, except: [:show, :new] do
        get 'sample_type_element', to: 'sample_types#sample_type_element'
        get 'destroy_confirmation', to: 'sample_types#destroy_confirmation'
      end
      resources :sample_groups, except: [:show, :new] do
        get 'sample_group_element', to: 'sample_groups#sample_group_element'
        get 'destroy_confirmation', to: 'sample_groups#destroy_confirmation'
      end
      resources :custom_fields, only: [:create, :edit, :update, :destroy] do
        get 'destroy_html'
      end
      member do
        post 'parse_sheet'
        post 'import_samples'
        post 'export_samples'
        post 'export_repository', to: 'repositories#export_repository'
        # Used for atwho (smart annotations)
        get 'atwho_users', to: 'at_who#users'
        get 'atwho_samples', to: 'at_who#samples'
        get 'atwho_projects', to: 'at_who#projects'
        get 'atwho_experiments', to: 'at_who#experiments'
        get 'atwho_my_modules', to: 'at_who#my_modules'
        get 'atwho_menu_items', to: 'at_who#menu_items'
      end
      match '*path',
            to: 'teams#routing_error',
            via: [:get, :post, :put, :patch]
    end

    get 'projects/archive', to: 'projects#archive', as: 'projects_archive'

    resources :projects, except: [:new, :destroy] do
      resources :user_projects, path: '/users',
                only: [:create, :index, :update, :destroy]
      resources :project_comments,
                path: '/comments',
                only: [:create, :index, :edit, :update, :destroy]
      # Activities popup (JSON) for individual project in projects index,
      # as well as all activities page for single project (HTML)
      resources :project_activities, path: '/activities', only: [:index]
      resources :tags, only: [:create, :update, :destroy]
      resources :reports,
                path: '/reports',
                only: [:index, :new, :create, :edit, :update] do
        collection do
          # The posts following here should in theory be gets,
          # but are posts because of parameters payload
          post 'generate', to: 'reports#generate'
          get 'new/', to: 'reports#new'
          get 'new/project_contents_modal',
              to: 'reports#project_contents_modal',
              as: :project_contents_modal
          post 'new/project_contents',
               to: 'reports#project_contents',
               as: :project_contents
          get 'new/experiment_contents_modal',
              to: 'reports#experiment_contents_modal',
              as: :experiment_contents_modal
          post 'new/experiment_contents',
               to: 'reports#experiment_contents',
               as: :experiment_contents
          get 'new/module_contents_modal',
              to: 'reports#module_contents_modal',
              as: :module_contents_modal
          post 'new/module_contents',
               to: 'reports#module_contents',
               as: :module_contents
          get 'new/step_contents_modal',
              to: 'reports#step_contents_modal',
              as: :step_contents_modal
          post 'new/step_contents',
               to: 'reports#step_contents',
               as: :step_contents
          get 'new/result_contents_modal',
              to: 'reports#result_contents_modal',
              as: :result_contents_modal
          post 'new/result_contents',
               to: 'reports#result_contents',
               as: :result_contents
          post '_save',
               to: 'reports#save_modal',
               as: :save_modal
          post 'destroy', as: :destroy # Destroy multiple entries at once
        end
      end
      resources :experiments,
                only: [:new, :create, :edit, :update],
                defaults: { format: 'json' }
      member do
        # Notifications popup for individual project in projects index
        get 'notifications'
        get 'samples' # Samples for single project
        # Renders sample datatable for single project (ajax action)
        post 'samples_index'
        get 'experiment_archive' # Experiment archive for single project
        post :delete_samples,
             constraints: CommitParamRouting.new(
               ProjectsController::DELETE_SAMPLES
             ),
             action: :delete_samples
      end

      # This route is defined outside of member block
      # to preserve original :project_id parameter in URL.
      get 'users/edit', to: 'user_projects#index_edit'
    end

    resources :experiments do
      member do
        get 'canvas' # Overview/structure for single experiment
        # AJAX-loaded canvas edit mode (from canvas)
        get 'canvas/edit', to: 'canvas#edit'
        get 'canvas/full_zoom', to: 'canvas#full_zoom' # AJAX-loaded canvas zoom
        # AJAX-loaded canvas zoom
        get 'canvas/medium_zoom', to: 'canvas#medium_zoom'
        get 'canvas/small_zoom', to: 'canvas#small_zoom' # AJAX-loaded canvas zoom
        post 'canvas', to: 'canvas#update' # Save updated canvas action
        get 'module_archive' # Module archive for single experiment
        get 'archive' # archive experiment
        get 'clone_modal' # return modal with clone options
        post 'clone' # clone experiment
        get 'move_modal' # return modal with move options
        post 'move' # move experiment
        get 'samples' # Samples for single project
        get 'updated_img' # Checks if the workflow image is updated
        get 'fetch_workflow_img' # Get udated workflow img
        # Renders sample datatable for single project (ajax action)
        post 'samples_index'
        post :delete_samples,
             constraints: CommitParamRouting.new(
               ExperimentsController::DELETE_SAMPLES
             ),
             action: :delete_samples
      end
    end

    # Show action is a popup (JSON) for individual module in full-zoom canvas,
    # as well as 'module info' page for single module (HTML)
    resources :my_modules, path: '/modules', only: [:show, :update] do
      resources :my_module_tags, path: '/tags', only: [:index, :create, :destroy]
      resources :user_my_modules, path: '/users',
                only: [:index, :create, :destroy]
      resources :my_module_comments,
                path: '/comments',
                only: [:index, :create, :edit, :update, :destroy]
      resources :sample_my_modules, path: '/samples_index', only: [:index]
      resources :result_texts, only: [:new, :create]
      resources :result_assets, only: [:new, :create]
      resources :result_tables, only: [:new, :create]
      member do
        # AJAX popup accessed from full-zoom canvas for single module,
        # as well as full activities view (HTML) for single module
        get 'description'
        get 'activities'
        get 'activities_tab' # Activities in tab view for single module
        get 'due_date'
        get 'protocols' # Protocols view for single module
        get 'results' # Results view for single module
        get 'samples' # Samples view for single module
        # Repository view for single module
        get 'repository/:repository_id',
            to: 'my_modules#repository',
            as: :repository
        post 'repository_index/:repository_id',
             to: 'my_modules#repository_index',
             as: :repository_index
        post 'assign_repository_records/:repository_id',
             to: 'my_modules#assign_repository_records',
             as: :assign_repository_records
        post 'unassign_repository_records/:repository_id',
             to: 'my_modules#unassign_repository_records',
             as: :unassign_repository_records
        get 'archive' # Archive view for single module
        get 'complete_my_module'
        post 'toggle_task_state'
        # Renders sample datatable for single module (ajax action)
        post 'samples_index'
        post :assign_samples,
             constraints: CommitParamRouting.new(
               MyModulesController::ASSIGN_SAMPLES
             ),
             action: :assign_samples
        post :assign_samples,
             constraints: CommitParamRouting.new(
               MyModulesController::UNASSIGN_SAMPLES
             ),
             action: :unassign_samples
        post :assign_samples,
             constraints: CommitParamRouting.new(
               MyModulesController::DELETE_SAMPLES
             ),
             action: :delete_samples
      end

      # Those routes are defined outside of member block
      # to preserve original id parameters in URL.
      get 'tags/edit', to: 'my_module_tags#index_edit'
      get 'users/edit', to: 'user_my_modules#index_edit'
    end

    resources :steps, only: [:edit, :update, :destroy, :show] do
      resources :step_comments,
                path: '/comments',
                only: [:create, :index, :edit, :update, :destroy]
      member do
        post 'checklistitem_state'
        post 'toggle_step_state'
        get 'move_down'
        get 'move_up'
      end
    end

    # tinyMCE image uploader endpoint
    post '/tinymce_assets', to: 'tiny_mce_assets#create', as: :tiny_mce_assets

    resources :results, only: [:update, :destroy] do
      resources :result_comments,
                path: '/comments',
                only: [:create, :index, :edit, :update, :destroy]
    end

    resources :samples, only: [:edit, :update, :destroy]
    get 'samples/:id', to: 'samples#show'

    resources :result_texts, only: [:edit, :update, :destroy]
    get 'result_texts/:id/download' => 'result_texts#download',
      as: :result_text_download
    resources :result_assets, only: [:edit, :update, :destroy]
    get 'result_assets/:id/download' => 'result_assets#download',
      as: :result_asset_download
    resources :result_tables, only: [:edit, :update, :destroy]
    get 'result_tables/:id/download' => 'result_tables#download',
      as: :result_table_download

    resources :protocols, only: [:index, :edit, :create] do
      resources :steps, only: [:new, :create]
      member do
        get 'linked_children', to: 'protocols#linked_children'
        post 'linked_children_datatable',
             to: 'protocols#linked_children_datatable'
        get 'preview', to: 'protocols#preview'
        patch 'metadata', to: 'protocols#update_metadata'
        patch 'keywords', to: 'protocols#update_keywords'
        post 'clone', to: 'protocols#clone'
        get 'unlink_modal', to: 'protocols#unlink_modal'
        post 'unlink', to: 'protocols#unlink'
        get 'revert_modal', to: 'protocols#revert_modal'
        post 'revert', to: 'protocols#revert'
        get 'update_parent_modal', to: 'protocols#update_parent_modal'
        post 'update_parent', to: 'protocols#update_parent'
        get 'update_from_parent_modal', to: 'protocols#update_from_parent_modal'
        post 'update_from_parent', to: 'protocols#update_from_parent'
        post 'load_from_repository_datatable',
             to: 'protocols#load_from_repository_datatable'
        get 'load_from_repository_modal',
            to: 'protocols#load_from_repository_modal'
        post 'load_from_repository', to: 'protocols#load_from_repository'
        post 'load_from_file', to: 'protocols#load_from_file'
        get 'copy_to_repository_modal', to: 'protocols#copy_to_repository_modal'
        post 'copy_to_repository', to: 'protocols#copy_to_repository'
        get 'protocol_status_bar', to: 'protocols#protocol_status_bar'
        get 'updated_at_label', to: 'protocols#updated_at_label'
        get 'edit_name_modal', to: 'protocols#edit_name_modal'
        get 'edit_keywords_modal', to: 'protocols#edit_keywords_modal'
        get 'edit_authors_modal', to: 'protocols#edit_authors_modal'
        get 'edit_description_modal', to: 'protocols#edit_description_modal'
      end
      collection do
        get 'create_new_modal', to: 'protocols#create_new_modal'
        post 'datatable', to: 'protocols#datatable'
        post 'make_private', to: 'protocols#make_private'
        post 'publish', to: 'protocols#publish'
        post 'archive', to: 'protocols#archive'
        post 'restore', to: 'protocols#restore'
        post 'import', to: 'protocols#import'
        get 'export', to: 'protocols#export'
      end
    end

    resources :repositories do
      post 'repository_index',
           to: 'repositories#repository_table_index',
           as: 'table_index',
           defaults: { format: 'json' }
      # Save repository table state
      post 'state_save',
           to: 'user_repositories#save_table_state',
           as: 'save_table_state',
           defaults: { format: 'json' }
      # Load repository table state
      post 'state_load',
           to: 'user_repositories#load_table_state',
           as: 'load_table_state',
           defaults: { format: 'json' }
      # Delete records from repository
      post 'delete_records',
           to: 'repository_rows#delete_records',
           as: 'delete_records',
           defaults: { format: 'json' }
      post 'repository_columns/:id/destroy_html',
           to: 'repository_columns#destroy_html',
           as: 'columns_destroy_html'

      resources :repository_columns, only: %i(create edit update destroy)

      resources :repository_rows, only: %i(create edit update)
      member do
        post 'parse_sheet'
        post 'import_records'
      end
    end

    get 'search' => 'search#index'
    get 'search/new' => 'search#new', as: :new_search

    # We cannot use 'resources :assets' because assets is a reserved route
    # in Rails (assets pipeline) and causes funky behavior
    get 'files/:id/present', to: 'assets#file_present', as: 'file_present_asset'
    get 'files/:id/large_url',
        to: 'assets#large_image_url',
        as: 'large_image_url_asset'
    get 'files/:id/download', to: 'assets#download', as: 'download_asset'
    get 'files/:id/preview', to: 'assets#preview', as: 'preview_asset'
    get 'files/:id/view', to: 'assets#view', as: 'view_asset'
    get 'files/:id/edit', to: 'assets#edit', as: 'edit_asset'
    post 'asset_signature' => 'assets#signature'

    devise_scope :user do
      get 'avatar/:id/:style' => 'users/registrations#avatar', as: 'avatar'
      post 'avatar_signature' => 'users/registrations#signature'
      get 'users/auth_token_sign_in' => 'users/sessions#auth_token_create'
    end
  end

  constraints WopiSubdomain do
    # Office integration
    get 'wopi/files/:id/contents', to: 'wopi#file_contents_get_endpoint'
    post 'wopi/files/:id/contents', to: 'wopi#file_contents_post_endpoint'
    get 'wopi/files/:id', to: 'wopi#file_get_endpoint', as: 'wopi_rest_endpoint'
    post 'wopi/files/:id', to: 'wopi#post_file_endpoint'
  end
end
