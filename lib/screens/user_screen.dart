import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  File? _avatar;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(LoadUser());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _avatar = File(pickedFile.path);
        });
        context.read<UserBloc>().add(UpdateUserPhoto(File(pickedFile.path)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка выбора изображения")),
      );
    }
  }

  void _saveUserData() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final location = _locationController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Все поля должны быть заполнены")),
      );
      return;
    }

    context.read<UserBloc>().add(UpdateUser(firstName: firstName, lastName: lastName, location: location));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Профиль пользователя")),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Данные сохранены!")),
            );
          }
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.red))),
            );
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserLoaded) {
              _firstNameController.text = state.user.firstName;
              _lastNameController.text = state.user.lastName;
              _locationController.text = state.user.location;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _avatar != null
                            ? FileImage(_avatar!)
                            : (state.user.avatarUrl.isNotEmpty
                                ? NetworkImage(state.user.avatarUrl) as ImageProvider
                                : null),
                        child: _avatar == null && state.user.avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text("Выбрать фото"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Имя'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Фамилия'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Город'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveUserData,
                      child: const Text("Сохранить"),
                    ),
                  ],
                ),
              );
            } else if (state is UserError) {
              return Center(
                child: Text(state.message, style: const TextStyle(color: Colors.red)),
              );
            }
            return const Center(child: Text("Нет данных"));
          },
        ),
      ),
    );
  }
}
