import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:condoview/providers/condominium_provider.dart';
import 'package:condoview/models/condominium_model.dart';
import 'package:condoview/screens/administrador/createCondo/create_admin_screen.dart';

class CreateCondoScreen extends StatefulWidget {
  const CreateCondoScreen({super.key});

  @override
  State<CreateCondoScreen> createState() => _CreateCondoScreenState();
}

class _CreateCondoScreenState extends State<CreateCondoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final condo = Condominium(
        name: _nameController.text,
        address: _addressController.text,
        cnpj: _cnpjController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        description: _descriptionController.text,
      );

      try {
        await Provider.of<CondoProvider>(context, listen: false)
            .createCondo(condo);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Condomínio criado com sucesso!')),
        );

        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const CreateAdminScreen()),
        );
      } catch (error) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar condomínio: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 78, 20, 166),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Criar condomínio',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dados do Condomínio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 78, 20, 166),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nome do Condomínio',
                    hint: 'Insira o nome do condomínio',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O nome do condomínio é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Endereço',
                    hint: 'Insira o endereço do condomínio',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O endereço é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cnpjController,
                    label: 'CNPJ',
                    hint: 'Insira o CNPJ do condomínio',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O CNPJ é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'E-mail',
                    hint: 'Insira o e-mail do condomínio',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O e-mail é obrigatório';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Telefone',
                    hint: 'Insira o telefone do condomínio',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O telefone é obrigatório';
                      } else if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
                        return 'Número de telefone inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Descrição',
                    hint: 'Insira a descrição do condomínio',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'A descrição é obrigatória';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 78, 20, 166),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'CONTINUAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 78, 20, 166),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }
}
