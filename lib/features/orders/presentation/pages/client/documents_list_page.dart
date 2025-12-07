import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/api/orders_api.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../auth/presentation/widgets/gradient_background.dart';
import '../../../domain/entities/contract.dart';

class DocumentsListPage extends StatefulWidget {
  final String orderId;

  const DocumentsListPage({super.key, required this.orderId});

  @override
  State<DocumentsListPage> createState() => _DocumentsListPageState();
}

class _DocumentsListPageState extends State<DocumentsListPage> {
  late final OrdersApi _ordersApi;
  List<Contract> _contracts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ordersApi = sl<OrdersApi>();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _ordersApi.getOrderById(widget.orderId);
      final contractsData = response['contracts'];

      List<Contract> contracts = [];
      if (contractsData != null) {
        if (contractsData is List) {
          contracts = contractsData
              .whereType<Map<String, dynamic>>()
              .map((json) => Contract.fromJson(json))
              .toList();
        } else if (contractsData is Map<String, dynamic>) {
          contracts = contractsData.values
              .whereType<Map<String, dynamic>>()
              .map((json) => Contract.fromJson(json))
              .toList();
        }
      }

      if (mounted) {
        setState(() {
          _contracts = contracts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showDocumentInfo(Contract contract) {
    if (contract.info != null && contract.info!.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                contract.title ?? 'Документ',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  height: 1.3,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                contract.info!,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  height: 1.3,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 20.h + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _buildErrorState()
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: Text(
              '􀰌',
              style: TextStyle(
                fontFamily: 'SF Compact',
                fontWeight: FontWeight.w600,
                fontSize: 26.sp,
                height: 1.193,
                color: AppColors.primaryText,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Мои документы',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w700,
              fontSize: 26.sp,
              height: 1.149,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ошибка загрузки',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _error!,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: const Color(0xFF96A4B3),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadContracts,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_contracts.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 28.h),
      child: Column(
        children: [
          ..._contracts.asMap().entries.map((entry) {
            final index = entry.key;
            final contract = entry.value;
            return Column(
              children: [
                _buildDocumentItem(contract),
                if (index < _contracts.length - 1) SizedBox(height: 16.h),
              ],
            );
          }),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64.w,
              color: AppColors.primaryText.withValues(alpha: 0.3),
            ),
            SizedBox(height: 24.h),
            Text(
              'Документы отсутствуют',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                height: 1.3,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'В этом проекте пока нет документов',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                height: 1.3,
                color: AppColors.primaryText.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(Contract contract) {
    return GestureDetector(
      onTap: () => _showDocumentInfo(contract),
      child: Container(
        width: 354.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                contract.title ?? 'Документ',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 17.sp,
                  height: 1.3,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              width: 9.28.w,
              child: Center(
                child: Text(
                  '􀆊',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 19.72.sp,
                    height: 1.294,
                    color: const Color(0xFFA9B6B9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
