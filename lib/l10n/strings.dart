import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/providers/settings_provider.dart';

class AppStrings {
  final String locale;

  const AppStrings(this.locale);

  bool get isZh => locale == 'zh';

  // Navigation
  String get tasks => isZh ? '任务' : 'Tasks';
  String get projects => isZh ? '项目' : 'Projects';
  String get notes => isZh ? '笔记' : 'Notes';
  String get inbox => isZh ? '收件箱' : 'Inbox';
  String get more => isZh ? '更多' : 'More';
  String get settings => isZh ? '设置' : 'Settings';

  // Auth / Login
  String get signIn => isZh ? '登录' : 'Sign In';
  String get email => isZh ? '邮箱' : 'Email';
  String get password => isZh ? '密码' : 'Password';
  String get changeServer => isZh ? '更换服务器' : 'Change Server';
  String get loginFailed => isZh ? '登录失败' : 'Login failed';
  String get emailRequired => isZh ? '邮箱不能为空' : 'Email is required';
  String get invalidEmail => isZh ? '无效的邮箱' : 'Invalid email';
  String get passwordRequired => isZh ? '密码不能为空' : 'Password is required';

  // Tasks
  String get newTask => isZh ? '新建任务' : 'New Task';
  String get editTask => isZh ? '编辑任务' : 'Edit Task';
  String get addTask => isZh ? '添加任务' : 'Add Task';
  String get noTasksYet => isZh ? '暂无任务\n点击 + 新建' : 'No tasks found.\nTap + to create one.';
  String get noTasksToday => isZh ? '今天没有任务啦。\n好好享受空闲时光！🎉' : 'No tasks for today.\nEnjoy your free time! 🎉';
  String get noCompletedTasks => isZh ? '还没有已完成的任务。' : 'No completed tasks yet.';
  String get retry => isZh ? '重试' : 'Retry';
  String get today => isZh ? '今天' : 'Today';
  String get upcoming => isZh ? '即将到来' : 'Upcoming';
  String get someday => isZh ? '某天' : 'Someday';
  String get completed => isZh ? '已完成' : 'Completed';
  String get save => isZh ? '保存' : 'Save';
  String get taskName => isZh ? '任务名称' : 'Task Name';
  String get taskNameHint => isZh ? '有哪些需要做的事？' : 'What needs to be done?';
  String get nameRequired => isZh ? '名称不能为空' : 'Name is required';
  String get priority => isZh ? '优先级' : 'Priority';
  String get low => isZh ? '低' : 'Low';
  String get medium => isZh ? '中' : 'Medium';
  String get high => isZh ? '高' : 'High';
  String get dueDate => isZh ? '截止日期' : 'Due Date';
  String get deferUntil => isZh ? '推迟至' : 'Defer Until';
  String get notSet => isZh ? '未设置' : 'Not set';
  String get project => isZh ? '项目' : 'Project';
  String get none => isZh ? '无' : 'None';
  String get recurrence => isZh ? '重复' : 'Recurrence';
  String get daily => isZh ? '每天' : 'Daily';
  String get weekly => isZh ? '每周' : 'Weekly';
  String get monthly => isZh ? '每月' : 'Monthly';
  String get noteDetail => isZh ? '备注' : 'Notes';
  String get noteHint => isZh ? '添加详情 (支持 Markdown)' : 'Add details (Markdown supported)';

  // Projects
  String get newProject => isZh ? '新建项目' : 'New Project';
  String get editProject => isZh ? '编辑项目' : 'Edit Project';
  String get projectTasks => isZh ? '项目任务' : 'Project Tasks';
  String get board => isZh ? '看板' : 'Board';
  String get list => isZh ? '列表' : 'List';
  String get noProjectsYet => isZh ? '暂无项目\n点击 + 新建' : 'No projects yet.\nTap + to create one.';
  String get projectName => isZh ? '项目名称' : 'Project Name';
  String get projectNameHint => isZh ? '最多6个词' : 'Max 6 words';
  String get desc => isZh ? '描述' : 'Description';
  String get status => isZh ? '状态' : 'Status';
  String get notStarted => isZh ? '未开始' : 'Not Started';
  String get planned => isZh ? '已计划' : 'Planned';
  String get cancelled => isZh ? '已取消' : 'Cancelled';
  String get area => isZh ? '区域' : 'Area';
  String get noArea => isZh ? '无区域' : 'No Area';
  String get pinSidebar => isZh ? '固定到侧边栏' : 'Pin to Sidebar';
  String get pinSidebarHint => isZh ? '方便从导航快速访问' : 'Quick access from navigation';

  // Kanban Statuses
  String get toDo => isZh ? '待办' : 'To Do';
  String get inProgress => isZh ? '进行中' : 'In Progress';
  String get done => isZh ? '已完成' : 'Done';
  String get waiting => isZh ? '等待中' : 'Waiting';
  String get other => isZh ? '其他' : 'Other';

  // Notes
  String get newNote => isZh ? '新建笔记' : 'New Note';
  String get editNote => isZh ? '编辑笔记' : 'Edit Note';
  String get noNotesYet => isZh ? '暂无笔记\n点击 + 新建' : 'No notes yet.\nTap + to create one.';
  String get noteTitle => isZh ? '笔记标题' : 'Note Title';
  String get titleRequired => isZh ? '标题不能为空' : 'Title is required';
  String get color => isZh ? '颜色' : 'Color';
  String get content => isZh ? '内容' : 'Content';
  String get contentHint => isZh ? '记下你的想法 (支持 Markdown)' : 'Jot down your thoughts (Markdown supported)';

  // Inbox
  String get inboxEmpty => isZh ? '收件箱为空' : 'Inbox is empty';
  String get inboxTelegramHint => isZh ? '来自 Telegram 的项目将显示在这里' : 'Items from Telegram will appear here';
  String get markProcessed => isZh ? '标记为已处理' : 'Mark as Processed';
  String get ignore => isZh ? '忽略' : 'Ignore';
  String get delete => isZh ? '删除' : 'Delete';

  // Settings
  String get navigation => isZh ? '导航' : 'Navigation';
  String get areas => isZh ? '区域管理' : 'Areas';
  String get areasDesc => isZh ? '将项目组织到不同区域' : 'Organize projects into areas';
  String get preferences => isZh ? '首选项' : 'Preferences';
  String get appearance => isZh ? '外观' : 'Appearance';
  String get language => isZh ? '语言' : 'Language';
  String get timezone => isZh ? '时区' : 'Timezone';
  String get integrations => isZh ? '集成' : 'Integrations';
  String get server => isZh ? '服务器' : 'Server';
  String get serverUrl => isZh ? '服务器地址' : 'Server URL';
  String get about => isZh ? '关于 Tududa' : 'About Tududa';
  String get signOut => isZh ? '退出登录' : 'Sign Out';
  String get signOutConfirm => isZh ? '确定要退出登录吗？' : 'Are you sure you want to sign out?';
  String get cancel => isZh ? '取消' : 'Cancel';
  
  // Theme Modes
  String get lightMode => isZh ? '浅色' : 'Light';
  String get darkMode => isZh ? '深色' : 'Dark';
  String get systemMode => isZh ? '跟随系统' : 'System';
}

extension AppStringsExtension on BuildContext {
  AppStrings get l10n {
    return ProviderScope.containerOf(this).read(stringsProvider);
  }
}
