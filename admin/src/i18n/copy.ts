export type Locale = 'vi' | 'en';

const vi = {
  dashboard: 'Tổng quan', contributions: 'Chờ duyệt', questionSets: 'Bộ câu hỏi', taxonomy: 'Môn học & chủ đề',
  users: 'Người dùng', media: 'Hình ảnh', account: 'Tài khoản', logout: 'Đăng xuất',
  adminConsole: 'Bảng quản trị', signIn: 'Đăng nhập quản trị', email: 'Email', password: 'Mật khẩu',
  signInHint: 'Sử dụng tài khoản StudyHub có role admin.', unauthorized: 'Tài khoản này không có quyền quản trị.',
  loading: 'Đang tải dữ liệu', retry: 'Thử lại', noData: 'Chưa có dữ liệu phù hợp.', search: 'Tìm kiếm',
  status: 'Trạng thái', subject: 'Môn học', topic: 'Chủ đề', contributor: 'Người đóng góp', questions: 'Câu hỏi',
  actions: 'Thao tác', review: 'Xem duyệt', approve: 'Duyệt', reject: 'Từ chối', reason: 'Lý do từ chối',
  confirmApprove: 'Xuất bản bộ câu hỏi này?', confirmReject: 'Từ chối đóng góp này?', cancel: 'Hủy', confirm: 'Xác nhận',
  totalUsers: 'Người dùng', totalSets: 'Bộ câu hỏi', pending: 'Chờ duyệt', approved: 'Đã duyệt', rejected: 'Từ chối', attempts: 'Lượt làm bài',
  recent: 'Hoạt động đóng góp gần đây', description: 'Mô tả', correctAnswer: 'Đáp án đúng', explanation: 'Giải thích',
  archive: 'Lưu trữ', restore: 'Khôi phục', edit: 'Chỉnh sửa', save: 'Lưu', create: 'Tạo mới', name: 'Tên',
  role: 'Vai trò', active: 'Hoạt động', disabled: 'Đã khóa', disable: 'Khóa', enable: 'Mở khóa',
  attemptsCount: 'Lượt làm', contributionsCount: 'Đóng góp', imageUsage: 'Vị trí ảnh', broken: 'Liên kết lỗi',
  all: 'Tất cả', previous: 'Trước', next: 'Sau', page: 'Trang', menu: 'Mở menu', close: 'Đóng',
  operationSuccess: 'Đã cập nhật thành công.', operationFailed: 'Không thể hoàn tất thao tác.', noPermission: 'Bạn cần đăng nhập bằng tài khoản admin.',
  profile: 'Quản trị viên hiện tại', settings: 'Cấu hình', source: 'Nguồn', system: 'Hệ thống', community: 'Cộng đồng',
  draft: 'Bản nháp', published: 'Đã xuất bản', admin: 'Quản trị viên', user: 'Người dùng',
};

const en: typeof vi = {
  dashboard: 'Overview', contributions: 'Pending reviews', questionSets: 'Question sets', taxonomy: 'Subjects & topics',
  users: 'Users', media: 'Media', account: 'Account', logout: 'Log out',
  adminConsole: 'Admin console', signIn: 'Admin sign in', email: 'Email', password: 'Password',
  signInHint: 'Use a StudyHub account with the admin role.', unauthorized: 'This account does not have administrator access.',
  loading: 'Loading data', retry: 'Try again', noData: 'No matching data yet.', search: 'Search',
  status: 'Status', subject: 'Subject', topic: 'Topic', contributor: 'Contributor', questions: 'Questions',
  actions: 'Actions', review: 'Review', approve: 'Approve', reject: 'Reject', reason: 'Rejection reason',
  confirmApprove: 'Publish this question set?', confirmReject: 'Reject this contribution?', cancel: 'Cancel', confirm: 'Confirm',
  totalUsers: 'Users', totalSets: 'Question sets', pending: 'Pending', approved: 'Approved', rejected: 'Rejected', attempts: 'Attempts',
  recent: 'Recent contribution activity', description: 'Description', correctAnswer: 'Correct answer', explanation: 'Explanation',
  archive: 'Archive', restore: 'Restore', edit: 'Edit', save: 'Save', create: 'Create', name: 'Name',
  role: 'Role', active: 'Active', disabled: 'Disabled', disable: 'Disable', enable: 'Enable',
  attemptsCount: 'Attempts', contributionsCount: 'Contributions', imageUsage: 'Image usage', broken: 'Broken reference',
  all: 'All', previous: 'Previous', next: 'Next', page: 'Page', menu: 'Open menu', close: 'Close',
  operationSuccess: 'Updated successfully.', operationFailed: 'The operation could not be completed.', noPermission: 'Sign in with an administrator account.',
  profile: 'Current administrator', settings: 'Configuration', source: 'Source', system: 'System', community: 'Community',
  draft: 'Draft', published: 'Published', admin: 'Administrator', user: 'User',
};

export const copy = { vi, en };
export type Copy = typeof vi;
