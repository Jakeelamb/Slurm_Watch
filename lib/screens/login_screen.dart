import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/frosted_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _saveCredentials = false;
  bool _isLoading = false;
  bool _testMode = true; // Default to test mode for easy testing
  
  @override
  void dispose() {
    _hostController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await Provider.of<AuthProvider>(context, listen: false).login(
        _hostController.text.isEmpty ? 'localhost' : _hostController.text,
        _usernameController.text.isEmpty ? 'test' : _usernameController.text,
        _passwordController.text.isEmpty ? 'test' : _passwordController.text,
        _saveCredentials,
        forceTestMode: _testMode,
      );
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed. Please check your credentials.')),
        );
      }
    } catch (error) {
      if (mounted) {
        // Show a better error message
        String errorMessage = 'Connection failed. ';
        if (_testMode) {
          errorMessage += 'Make sure backend is running or try with test mode enabled.';
        } else {
          errorMessage += error.toString();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;
    
    return FrostedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: isDesktop ? 400 : size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App title
                  const Text(
                    'SWATCH',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Slurm Workflow and Task Control Hub',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  
                  // Host field
                  TextFormField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'Hostname',
                      hintText: 'Enter Slurm host (e.g., cluster.example.edu)',
                      prefixIcon: Icon(Icons.computer),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (!_testMode && (value == null || value.isEmpty)) {
                        return 'Please enter a hostname';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (!_testMode && (value == null || value.isEmpty)) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (!_testMode && (value == null || value.isEmpty)) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Save credentials checkbox
                  CheckboxListTile(
                    title: const Text('Save credentials'),
                    value: _saveCredentials,
                    onChanged: (value) {
                      setState(() {
                        _saveCredentials = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  // Test mode toggle
                  CheckboxListTile(
                    title: const Text('Test mode'),
                    subtitle: const Text('Use mock data instead of real connection'),
                    value: _testMode,
                    onChanged: (value) {
                      setState(() {
                        _testMode = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login', style: TextStyle(fontSize: 16)),
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
} 