import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/category/category_create.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/staff/addstaff.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/user/adduser.dart';

Widget planUpgrade(context) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    child: Row(
      children: [
        const Text(
          "Upgrade to",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Text(
            "PRO",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(
          width: 10,
        ),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Icon(
            Icons.north_east_outlined,
            size: 20,
          ),
        ),
      ],
    ),
  );
}

Widget inputForm(
  context, {
  required TextEditingController controller,
  required String lableName,
  required String formName,
  TextInputType? keyboardType,
  IconData? prefixIcon,
  bool? isPasswordForm,
}) {
  bool passwordVisable = true;
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lableName,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            cursorColor: const Color(0xff7099c2),
            keyboardType: keyboardType ?? TextInputType.text,
            decoration: InputDecoration(
              hintText: formName,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: const Color(0xff7099c2),
                    )
                  : null,
              suffixIcon: isPasswordForm != null
                  ? passwordVisable == true
                      ? IconButton(
                          onPressed: () {
                            passwordVisable = false;
                          },
                          icon: const Icon(
                            Icons.remove_red_eye,
                            color: Color(0xff7099c2),
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            passwordVisable = true;
                          },
                          icon: const Icon(
                            Icons.visibility_off,
                            color: Color(0xff7099c2),
                          ),
                        )
                  : null,
            ),
            obscureText: isPasswordForm != null ? passwordVisable : false,
          ),
        ],
      ),
    ),
  );
}

class DropDownForm extends StatefulWidget {
  final String labelName;
  final void Function(String?)? onChange;
  final String? value;
  final List<DropdownMenuItem<String>>? listItems;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final String formName;
  const DropDownForm({
    super.key,
    required this.onChange,
    required this.labelName,
    required this.value,
    required this.listItems,
    this.prefixIcon,
    this.validator,
    this.onTap,
    required this.formName,
  });

  @override
  State<DropDownForm> createState() => _DropDownFormState();
}

class _DropDownFormState extends State<DropDownForm> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelName,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          DropdownButtonFormField<String>(
            onTap: widget.onTap,
            value: widget.value,
            items: widget.listItems,
            onChanged: widget.onChange,
            isExpanded: true,
            decoration: InputDecoration(
              fillColor: const Color(0xfff1f5f9),
              filled: true,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              hintText: widget.labelName,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: const Color(0xff7099c2),
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "${widget.formName} is Must";
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    );
  }
}

class InputForm extends StatefulWidget {
  final TextEditingController controller;
  final String? lableName;
  final String formName;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool? isPasswordForm;
  final String? Function(String? input)? validation;
  final void Function(String value)? onChanged;
  final List<TextInputFormatter>? inputFormaters;
  final bool? readOnly;
  final Function()? onTap;

  const InputForm({
    super.key,
    required this.controller,
    this.lableName,
    required this.formName,
    this.keyboardType,
    this.prefixIcon,
    this.isPasswordForm,
    this.validation,
    this.onChanged,
    this.inputFormaters,
    this.readOnly,
    this.onTap,
  });

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  bool passwordVisable = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.lableName != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lableName!.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  )
                : const SizedBox(),
            TextFormField(
              readOnly: widget.readOnly ?? false,
              controller: widget.controller,
              cursorColor: const Color(0xff7099c2),
              keyboardType: widget.keyboardType ?? TextInputType.text,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              inputFormatters: widget.inputFormaters,
              decoration: InputDecoration(
                hintText: widget.formName,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: const Color(0xff7099c2),
                      )
                    : null,
                suffixIcon: widget.isPasswordForm != null
                    ? passwordVisable == true
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                passwordVisable = false;
                              });
                            },
                            icon: const Icon(
                              Icons.remove_red_eye,
                              color: Color(0xff7099c2),
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                passwordVisable = true;
                              });
                            },
                            icon: const Icon(
                              Icons.visibility_off,
                              color: Color(0xff7099c2),
                            ),
                          )
                    : null,
              ),
              obscureText: widget.isPasswordForm != null ? passwordVisable : false,
              validator: widget.validation,
            ),
          ],
        ),
      ),
    );
  }
}

Widget fillButton(context, {required Function() onTap, required String btnName}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).primaryColor,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      width: double.infinity,
      child: Center(
        child: Text(
          btnName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}

Widget outlinButton(context, {required Function() onTap, required String btnName}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).primaryColor.withOpacity(0.15),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      width: double.infinity,
      child: Center(
        child: Text(
          btnName,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}

Future openModelBottomSheat(context) async {
  return await showModalBottomSheet(
    enableDrag: false,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    context: context,
    builder: (builder) {
      return const AddUser();
    },
  );
}

Future<bool?> addStaffForm(context, {required String companyID}) async {
  return await showModalBottomSheet(
    enableDrag: false,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    context: context,
    builder: (builder) {
      return AddStaff(
        companyID: companyID,
      );
    },
  );
}

Future addCategoryForm(context, {bool? isedit, String? categoryName, String? docID}) async {
  return await showModalBottomSheet(
    enableDrag: false,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    context: context,
    builder: (builder) {
      return CategoryCreate(
        isEdit: isedit,
        categoryName: categoryName,
        docID: docID,
      );
    },
  );
}

class SearchForm extends StatefulWidget {
  final TextEditingController controller;
  final String formName;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final void Function(String)? onChanged;

  const SearchForm({
    super.key,
    required this.controller,
    required this.formName,
    this.keyboardType,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: widget.controller,
        cursorColor: const Color(0xff7099c2),
        keyboardType: widget.keyboardType ?? TextInputType.text,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          hintText: widget.formName,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: const Color(0xff7099c2),
                )
              : null,
        ),
      ),
    );
  }
}

Widget futureLoading(context) {
  return Center(
    child: Container(
      height: 50,
      width: 50,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: Theme.of(context).primaryColor,
      ),
    ),
  );
}

Future<bool?> confirmationDialog(
  context, {
  required String title,
  required String message,
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoButton(
              child: const Text("Confirm"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            CupertinoButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<bool?> confirmationDialogNew(
  context, {
  required String title,
  required String message,
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            CupertinoButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            CupertinoButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<bool?> orderDialog(
  context, {
  required String title,
  required String message,
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            CupertinoButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            CupertinoButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<Map<String, dynamic>?> formDialog(
  context, {
  required String title,
  required String sysmbol,
  required String value,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CartFormAlert(
        title: title,
        sysmbol: sysmbol,
        value: value,
      );
    },
  );
}

class CartFormAlert extends StatefulWidget {
  final String title;
  final String sysmbol;
  final String value;
  const CartFormAlert({
    super.key,
    required this.title,
    required this.sysmbol,
    required this.value,
  });

  @override
  State<CartFormAlert> createState() => _CartFormAlertState();
}

class _CartFormAlertState extends State<CartFormAlert> {
  String sys = "%";
  TextEditingController value = TextEditingController();

  List<DropdownMenuItem> sysList = const [
    DropdownMenuItem(
      value: "%",
      child: Text("%"),
    ),
    DropdownMenuItem(
      value: "rs",
      child: Text("RS"),
    ),
  ];

  @override
  void initState() {
    super.initState();
    sys = widget.sysmbol;
    value.text = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: AlertDialog(
        title: Text(widget.title),
        content: Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField(
                isExpanded: true,
                value: sys,
                items: sysList,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    sys = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 6,
              child: TextFormField(
                autofocus: true,
                controller: value,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                FocusManager.instance.primaryFocus!.unfocus();
              });
              Navigator.pop(context, {"sys": sys, "value": double.parse(value.text).toStringAsFixed(2)});
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
      onWillPop: () async => false,
    );
  }
}

class EmptyListPage extends StatefulWidget {
  final String assetsPath;
  final String title;
  final String content;
  final void Function() addFun;
  final void Function() refreshFun;
  const EmptyListPage(
      {super.key,
      required this.assetsPath,
      required this.title,
      required this.content,
      required this.addFun,
      required this.refreshFun});

  @override
  State<EmptyListPage> createState() => _EmptyListPageState();
}

class _EmptyListPageState extends State<EmptyListPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: AspectRatio(
              aspectRatio: (1 / 0.7),
              child: SvgPicture.asset(widget.assetsPath),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              widget.content,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: widget.addFun,
                icon: const Icon(Icons.add),
                label: const Text("Add User"),
              ),
              TextButton.icon(
                onPressed: widget.refreshFun,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
