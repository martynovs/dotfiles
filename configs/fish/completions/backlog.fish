# Fish completion for backlog CLI

# Helper function to check if we're in a specific command context
function __fish_backlog_needs_command
    set cmd (commandline -opc)
    if [ (count $cmd) -eq 1 ]
        return 0
    end
    return 1
end

function __fish_backlog_using_command
    set cmd (commandline -opc)
    if [ (count $cmd) -gt 1 ]
        if [ $argv[1] = $cmd[2] ]
            return 0
        end
        # Handle 'tasks' alias for 'task'
        if [ $argv[1] = "task" ] && [ "tasks" = $cmd[2] ]
            return 0
        end
    end
    return 1
end

function __fish_backlog_using_subcommand
    set cmd (commandline -opc)
    if [ (count $cmd) -gt 2 ]
        if [ $argv[1] = $cmd[2] ] && [ $argv[2] = $cmd[3] ]
            return 0
        end
        # Handle 'tasks' alias for 'task'
        if [ $argv[1] = "task" ] && [ "tasks" = $cmd[2] ] && [ $argv[2] = $cmd[3] ]
            return 0
        end
    end
    return 1
end

function __fish_backlog_needs_subcommand
    set cmd (commandline -opc)
    if [ (count $cmd) -eq 2 ]
        if contains $cmd[2] task tasks draft board doc decision config
            return 0
        end
    end
    return 1
end

# Main command completions
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'init' -d 'Initialize backlog project in the current repository'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'task tasks' -d 'Manage tasks'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'draft' -d 'Manage drafts'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'board' -d 'Display tasks in a Kanban board'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'doc' -d 'Manage documents'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'decision' -d 'Manage decisions'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'agents' -d 'Manage agent instruction files'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'config' -d 'Manage configuration'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'cleanup' -d 'Move completed tasks to completed folder based on age'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'browser' -d 'Open browser interface for task management'
complete -c backlog -f -n '__fish_backlog_needs_command' -a 'overview' -d 'Display project statistics and metrics'

# Global options
complete -c backlog -s v -l version -d 'Display version number'

# Init command options
complete -c backlog -f -n '__fish_backlog_using_command init' -l agent-instructions -d 'Comma-separated list of agent instructions to create'
complete -c backlog -f -n '__fish_backlog_using_command init' -l check-branches -d 'Check task states across active branches (default: true)'
complete -c backlog -f -n '__fish_backlog_using_command init' -l include-remote -d 'Include remote branches when checking (default: true)'
complete -c backlog -f -n '__fish_backlog_using_command init' -l branch-days -d 'Days to consider branch active (default: 30)'
complete -c backlog -f -n '__fish_backlog_using_command init' -l bypass-git-hooks -d 'Bypass git hooks when committing (default: false)'
complete -c backlog -f -n '__fish_backlog_using_command init' -l zero-padded-ids -d 'Number of digits for zero-padding IDs (0 to disable)'
complete -c backlog -f -n '__fish_backlog_using_command init' -l default-editor -d 'Default editor command'
complete -c backlog -f -n '__fish_backlog_using_command init' -l web-port -d 'Default web UI port (default: 6420)'
complete -c backlog -f -n '__fish_backlog_using_command init' -l auto-open-browser -d 'Auto-open browser for web UI (default: true)'
complete -c backlog -f -n '__fish_backlog_using_command init' -l install-claude-agent -d 'Install Claude Code agent (default: false)'
complete -c backlog -f -n '__fish_backlog_using_command init' -l defaults -d 'Use default values for all prompts'

# Task/Tasks command subcommands - only show when we need a subcommand
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command task' -a 'create' -d 'Create a new task'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command task' -a 'list' -d 'List tasks grouped by status'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command task' -a 'edit' -d 'Edit an existing task'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command task' -a 'view' -d 'Display task details'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command task' -a 'archive' -d 'Archive a task'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command task' -a 'demote' -d 'Move task back to drafts'

# Task command options - show for both 'task' and 'tasks' at command level
complete -c backlog -f -n '__fish_backlog_using_command task' -l plain -d 'Use plain text output'
complete -c backlog -f -n '__fish_backlog_using_command tasks' -l plain -d 'Use plain text output'

# Task create subcommand options
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -s d -l description -d 'Task description'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -l desc -d 'Alias for --description'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -s a -l assignee -d 'Task assignee'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -s s -l status -d 'Task status'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -s l -l labels -d 'Task labels'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -l priority -r -d 'Set task priority' -a 'high medium low'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -l ac -d 'Add acceptance criteria'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -l acceptance-criteria -d 'Add acceptance criteria'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -l plan -d 'Add implementation plan'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -l notes -d 'Add implementation notes'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -l draft -d 'Create as draft'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -s p -l parent -d 'Specify parent task ID'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -l depends-on -d 'Specify task dependencies'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -l dep -d 'Specify task dependencies (shortcut)'

# Task create flag suggestions (show common flags without typing dash)
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -a '--description' -d 'Task description'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -a '--assignee' -d 'Task assignee'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -a '--status' -d 'Task status'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -a '--labels' -d 'Task labels'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -a '--priority' -d 'Set task priority'
complete -c backlog -f -n '__fish_backlog_using_subcommand task create' -a '--draft' -d 'Create as draft'

# Disable file completion for task create when no flags are being typed
complete -c backlog -f -n '__fish_backlog_using_subcommand task create'

# Task list subcommand options
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -s s -l status -d 'Filter tasks by status'
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -s a -l assignee -d 'Filter tasks by assignee'
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -s p -l parent -d 'Filter tasks by parent task ID'
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -l priority -r -d 'Filter tasks by priority' -a 'high medium low'
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -l sort -r -d 'Sort tasks by field' -a 'priority id'
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -l plain -d 'Use plain text output instead of interactive UI'

# Task list flag suggestions
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -a '--status' -d 'Filter tasks by status'
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -a '--assignee' -d 'Filter tasks by assignee'
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -a '--priority' -d 'Filter tasks by priority'
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -a '--sort' -d 'Sort tasks by field'
complete -c backlog -f -n '__fish_backlog_using_subcommand task list' -a '--plain' -d 'Use plain text output'

# Disable file completion for task list
complete -c backlog -f -n '__fish_backlog_using_subcommand task list'

# Task edit subcommand options
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -s t -l title -d 'Task title'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -s d -l description -d 'Task description'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l desc -d 'Alias for --description'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -s a -l assignee -d 'Task assignee'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -s s -l status -d 'Task status'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -s l -l label -d 'Task labels'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l priority -r -d 'Set task priority' -a 'high medium low'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l ordinal -d 'Set task ordinal for custom ordering'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l add-label -d 'Add label'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l remove-label -d 'Remove label'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l ac -d 'Set acceptance criteria'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l acceptance-criteria -d 'Set acceptance criteria'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l plan -d 'Set implementation plan'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l notes -d 'Add implementation notes'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l depends-on -d 'Set task dependencies'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -l dep -d 'Set task dependencies (shortcut)'

# Task edit flag suggestions
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -a '--title' -d 'Task title'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -a '--description' -d 'Task description'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -a '--assignee' -d 'Task assignee'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -a '--status' -d 'Task status'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -a '--priority' -d 'Set task priority'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -a '--add-label' -d 'Add label'
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit' -a '--remove-label' -d 'Remove label'

# Disable file completion for task edit
complete -c backlog -f -n '__fish_backlog_using_subcommand task edit'

# Task view subcommand options
complete -c backlog -f -n '__fish_backlog_using_subcommand task view' -l plain -d 'Use plain text output instead of interactive UI'

# Task view flag suggestions
complete -c backlog -f -n '__fish_backlog_using_subcommand task view' -a '--plain' -d 'Use plain text output'

# Task archive and demote subcommands (they just take taskId)

# Task archive/demote flag suggestions
complete -c backlog -f -n '__fish_backlog_using_subcommand task archive'
complete -c backlog -f -n '__fish_backlog_using_subcommand task demote'

# Disable file completion for task view, archive, and demote
complete -c backlog -f -n '__fish_backlog_using_subcommand task view'
complete -c backlog -f -n '__fish_backlog_using_subcommand task archive'
complete -c backlog -f -n '__fish_backlog_using_subcommand task demote'

# Draft command subcommands - only show when we need a subcommand
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command draft' -a 'list' -d 'List all drafts'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command draft' -a 'create' -d 'Create a new draft'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command draft' -a 'archive' -d 'Archive a draft'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command draft' -a 'promote' -d 'Promote draft to task'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command draft' -a 'view' -d 'Display draft details'

# Draft command options
complete -c backlog -f -n '__fish_backlog_using_command draft' -l plain -d 'Use plain text output'

# Draft create subcommand options
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create' -s d -l description -d 'Draft description'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create' -l desc -d 'Alias for --description'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create' -s a -l assignee -d 'Draft assignee'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create' -s s -l status -d 'Draft status'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create' -s l -l labels -d 'Draft labels'

# Draft create flag suggestions
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create' -a '--description' -d 'Draft description'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create' -a '--assignee' -d 'Draft assignee'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create' -a '--status' -d 'Draft status'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create' -a '--labels' -d 'Draft labels'

# Draft view subcommand options
complete -c backlog -f -n '__fish_backlog_using_subcommand draft view' -l plain -d 'Use plain text output instead of interactive UI'

# Disable file completion for all draft subcommands
complete -c backlog -f -n '__fish_backlog_using_subcommand draft create'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft list'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft view'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft archive'
complete -c backlog -f -n '__fish_backlog_using_subcommand draft promote'

# Board command subcommands - only show when we need a subcommand
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command board' -a 'view' -d 'Display tasks in a Kanban board'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command board' -a 'export' -d 'Export kanban board to markdown file'

# Board command options
complete -c backlog -f -n '__fish_backlog_using_command board' -s l -l layout -r -d 'Board layout' -a 'horizontal vertical'
complete -c backlog -f -n '__fish_backlog_using_command board' -l vertical -d 'Use vertical layout (shortcut for --layout vertical)'

# Board flag suggestions
complete -c backlog -f -n '__fish_backlog_using_command board' -a '--layout' -d 'Board layout'
complete -c backlog -f -n '__fish_backlog_using_command board' -a '--vertical' -d 'Use vertical layout'

# Board export subcommand options
complete -c backlog -f -n '__fish_backlog_using_subcommand board export' -l force -d 'Overwrite existing file without confirmation'
complete -c backlog -f -n '__fish_backlog_using_subcommand board export' -l readme -d 'Export to README.md with markers'
complete -c backlog -f -n '__fish_backlog_using_subcommand board export' -l export-version -d 'Version to include in the export'

# Board view subcommand options (inherits from main board command)
complete -c backlog -f -n '__fish_backlog_using_subcommand board view' -s l -l layout -r -d 'Board layout' -a 'horizontal vertical'
complete -c backlog -f -n '__fish_backlog_using_subcommand board view' -l vertical -d 'Use vertical layout'

# Disable file completion for board subcommands
complete -c backlog -f -n '__fish_backlog_using_subcommand board view'
complete -c backlog -f -n '__fish_backlog_using_subcommand board export'

# Doc command subcommands - only show when we need a subcommand
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command doc' -a 'create' -d 'Create a new document'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command doc' -a 'list' -d 'List documents'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command doc' -a 'view' -d 'View a document'

# Doc create subcommand options
complete -c backlog -f -n '__fish_backlog_using_subcommand doc create' -s p -l path -d 'Document path'
complete -c backlog -f -n '__fish_backlog_using_subcommand doc create' -s t -l type -d 'Document type'

# Disable file completion for doc subcommands
complete -c backlog -f -n '__fish_backlog_using_subcommand doc create'
complete -c backlog -f -n '__fish_backlog_using_subcommand doc list'
complete -c backlog -f -n '__fish_backlog_using_subcommand doc view'

# Decision command subcommands - only show when we need a subcommand
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command decision' -a 'create' -d 'Create a new decision'

# Decision create subcommand options
complete -c backlog -f -n '__fish_backlog_using_subcommand decision create' -s s -l status -d 'Decision status'

# Disable file completion for decision subcommands
complete -c backlog -f -n '__fish_backlog_using_subcommand decision create'

# Agents command options
complete -c backlog -f -n '__fish_backlog_using_command agents' -l update-instructions -d 'Update agent instruction files'

# Browser command options
complete -c backlog -f -n '__fish_backlog_using_command browser' -s p -l port -d 'Port to run server on'
complete -c backlog -f -n '__fish_backlog_using_command browser' -l no-open -d "Don't automatically open browser"

# Browser flag suggestions
complete -c backlog -f -n '__fish_backlog_using_command browser' -a '--port' -d 'Port to run server on'
complete -c backlog -f -n '__fish_backlog_using_command browser' -a '--no-open' -d "Don't automatically open browser"

# Disable file completion for commands that only have flags
complete -c backlog -f -n '__fish_backlog_using_command agents'
complete -c backlog -f -n '__fish_backlog_using_command browser'
complete -c backlog -f -n '__fish_backlog_using_command cleanup'
complete -c backlog -f -n '__fish_backlog_using_command overview'

# Config command subcommands - only show when we need a subcommand
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command config' -a 'get' -d 'Get a configuration value'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command config' -a 'set' -d 'Set a configuration value'
complete -c backlog -f -n '__fish_backlog_needs_subcommand; and __fish_backlog_using_command config' -a 'list' -d 'List all configuration values'

# Disable file completion for config subcommands
complete -c backlog -f -n '__fish_backlog_using_subcommand config get'
complete -c backlog -f -n '__fish_backlog_using_subcommand config set'
complete -c backlog -f -n '__fish_backlog_using_subcommand config list'
