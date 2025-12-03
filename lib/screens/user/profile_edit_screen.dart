import 'package:flutter/material.dart';
import 'package:sajunara_app/services/api/user_api.dart';
import 'package:sajunara_app/utils/token_service.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TokenService _tokenService = TokenService();
  final UserApi _api = UserApi();
  bool _isLoggedIn = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  String? _selectedBirthTime;
  String? userBirthday;
  TextEditingController _phoneController = TextEditingController();

  // 태어난 시간 목록
  final List<Map<String, String>> birthTimes = [
    {'label': '자시', 'time': '23:30-1:30'},
    {'label': '축시', 'time': '1:30-3:30'},
    {'label': '인시', 'time': '3:30-5:30'},
    {'label': '묘시', 'time': '3:30-7:30'},
    {'label': '진시', 'time': '7:30-9:30'},
    {'label': '사시', 'time': '9:30-11:30'},
    {'label': '오시', 'time': '11:30-13:30'},
    {'label': '미시', 'time': '13:30-15:30'},
    {'label': '신시', 'time': '15:30-17:30'},
    {'label': '유시', 'time': '17:30-19:30'},
    {'label': '술시', 'time': '19:30-21:30'},
    {'label': '해시', 'time': '21:30-23:30'},
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _tokenService.isLoggedIn();

    if (isLoggedIn) {
      final userInfo = await _tokenService.getUserInfo();
      if (userInfo != null) {
        // 사용자 정보 로드
        _loadMyUserInfo();
        setState(() {
          _isLoggedIn = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMyUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userSeq = await _tokenService.getUserSeq();
      final data = await _api.fetchUserData(requestBody: {'seq': userSeq});
      setState(() {
        _user = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 예약 목록 조회 에러: $e');
      setState(() {
        _user = {};
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('예약 목록을 불러오는 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userSeq = await _tokenService.getUserSeq();
      final data = await _api.updateUserProfile(
        requestBody: {'seq': userSeq, 'birthTime': _selectedBirthTime, 'phone': _phoneController.text},
      );
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정보가 수정되었습니다'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
        );
        _loadMyUserInfo();
      }
    } catch (e) {
      print('❌ 프로필 수정 에러: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정보 수정 중 오류가 발생했습니다'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
        );
      }
    }
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.pushNamed(context, '/login');

    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      await _checkLoginStatus();
    }
  }

  void _selectBirthTime() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('취소', style: TextStyle(color: Colors.grey)),
                    ),
                    Text('태어난 시간 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('확인', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: birthTimes.length,
                  itemBuilder: (context, index) {
                    final item = birthTimes[index];
                    final displayText = '${item['label']} ${item['time']}';
                    var userbirthTime;
                    final currentValue = _selectedBirthTime ?? userbirthTime;

                    return ListTile(
                      title: Center(
                        child: Text(
                          displayText,
                          style: TextStyle(
                            fontSize: 16,
                            color: currentValue == displayText ? Colors.blue : Colors.black,
                            fontWeight: currentValue == displayText ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedBirthTime = displayText;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('내 정보 수정'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isLoggedIn
          ? _buildEditForm()
          : _buildLoginRequired(),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '로그인이 필요한 서비스입니다',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text('내 정보를 수정하려면 로그인해주세요', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('로그인하기', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    final userName = _user?['memberName']?.toString() ?? '사용자';
    final userBirthDate = _user?['birthYear']?.toString() ?? '';
    final userBirthday = _user?['birthday']?.toString() ?? '';
    final userbirthTime = _user?['birthTime']?.toString() ?? '';
    final gender = (_user?['gender']?.toString() ?? '0') == '0' ? '남자' : '여자';
    final phone = _user?['phone']?.toString() ?? '';
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 성별 (disabled)
            Text(
              '성별 *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('남자', style: TextStyle(color: Colors.grey)),
                    value: '남자',
                    groupValue: gender,
                    onChanged: null, // disabled
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('여자', style: TextStyle(color: Colors.grey)),
                    value: '여자',
                    groupValue: gender,
                    onChanged: null, // disabled
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // 이름 (disabled)
            Text(
              '이름 *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 12),
            TextField(
              enabled: false, // disabled
              decoration: InputDecoration(
                hintText: userName,
                hintStyle: TextStyle(color: Colors.grey[700]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
              ),
            ),
            SizedBox(height: 24),

            // 생년월일 (disabled)
            Text(
              '생년월일 *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${userBirthDate}-${userBirthday}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  Icon(Icons.calendar_today, color: Colors.grey[400]),
                ],
              ),
            ),
            SizedBox(height: 24),

            // 태어난 시간 (enabled)
            Text('태어난 시간 *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            GestureDetector(
              onTap: _selectBirthTime,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedBirthTime ?? userbirthTime ?? '태어난 시간을 선택하세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: (_selectedBirthTime ?? userbirthTime) != null ? Colors.black : Colors.grey,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // 휴대폰 (enabled)

            // TextField에서 사용
            Text('휴대폰 *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              controller: _phoneController..text = phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '휴대폰 번호를 입력하세요',
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            SizedBox(height: 32),

            // 수정하기 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('수정하기', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
