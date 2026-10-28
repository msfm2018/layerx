import 'package:material_ui/material_ui.dart';
import 'package:layerx/layerx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 全局模式初始化（最简写法）
      builder: LayerX.init(),
      title: 'LayerX Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'LayerX Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    /// 全局配置（丝滑体验）
    LayerX.config(
      delay: const Duration(milliseconds: 150),
      minShow: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              LayerX.alert(
                '返回键测试说明：\n\n'
                '弹出 confirm / custom 后，按手机返回键，\n'
                '应该关闭最上层弹窗，而不是直接退出页面。',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ================= Dialog =================
          const _SectionTitle('Dialog'),
          _btn('confirm', () async {
            final r = await LayerX.confirm('Are you sure to continue?');
            LayerX.toast('Result: $r');
          }),
          _btn('show', () async {
            await LayerX.show("This is a message");
          }),
          _btn('alert', () async {
            await LayerX.alert('Operation completed!');
          }),
          _btn('input ⭐', () async {
            final text = await LayerX.input();
            LayerX.toast('Input: $text');
          }),
          _btn('custom ⭐', () async {
            final result = await LayerX.custom<String>(
              Builder(
                builder: (context) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Custom Dialog',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          const Text('You can put any widget here'),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  LayerX.dismiss(context, "cancel");
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  LayerX.dismiss(context, "hello custom");
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
            print('custom result: $result');
            LayerX.toast('Custom result: $result');
          }),

          /// ================= Bottom =================
          const _SectionTitle('BottomSheet / ActionSheet'),
          _btn('bottomSheet ⭐', () {
            LayerX.bottomSheet(
              Container(
                padding: const EdgeInsets.all(20),
                height: 200,
                child: const Center(child: Text('This is a BottomSheet')),
              ),
            );
          }),
          _btn('actionSheet ⭐', () async {
            final i = await LayerX.actionSheet(
              options: ['Camera', 'Gallery', 'Delete'],
            );
            LayerX.toast('Selected index: $i');
          }),

          /// ================= Loading =================
          const _SectionTitle('Loading'),
          _btn('loading（manual）', () async {
            LayerX.loading(message: 'Loading...');
            await Future.delayed(const Duration(seconds: 2));
            LayerX.dismissLoading();
          }),
          _btn('wrapLoading ⭐（recommended）', () async {
            await LayerX.wrapLoading(() async {
              await Future.delayed(const Duration(seconds: 2));
            });
            LayerX.toast('Done');
          }),
          _btn('concurrent loading (queue test)', () async {
            await Future.wait([
              LayerX.wrapLoading(() async {
                await Future.delayed(const Duration(seconds: 2));
              }),
              LayerX.wrapLoading(() async {
                await Future.delayed(const Duration(seconds: 3));
              }),
            ]);
            LayerX.toast('All tasks completed');
          }),

          /// ================= Progress =================
          const _SectionTitle('Progress'),
          _btn('progress ⭐', () async {
            for (int i = 0; i <= 10; i++) {
              LayerX.progress(i / 10);
              await Future.delayed(const Duration(milliseconds: 200));
            }
            LayerX.dismissProgress();
            LayerX.toast('Progress finished');
          }),

          /// ================= Toast (带/不带 context 对比) =================
          const _SectionTitle('Toast / Notification'),
          
          // 1. 不带 context 形式
          _btn('toast (without context)', () {
            LayerX.toast('This is a toast without context');
          }),

          // 2. 带 context 形式（自动适配 Theme 主题）
          _btn('toast (with context)', () {
            LayerX.toast('This is a toast with context', context: context);
          }),

          _btn('toast (from center)', () {
            LayerX.toast('Center toast', fromBottom: false, context: context);
          }),

          _btn('toast (long duration)', () {
            LayerX.toast(
              'This toast stays longer',
              duration: const Duration(seconds: 4),
            );
          }),

          _btn('notification', () {
            LayerX.notification(
              title: 'New Message',
              message: 'You have an unread message',
            );
          }),

          /// ================= 全局控制 =================
          const _SectionTitle('Global Control'),
          _btn('dismissAll ⭐', () {
            LayerX.confirm('Dialog 1');
            Future.delayed(const Duration(milliseconds: 400), () {
              LayerX.confirm('Dialog 2');
            });
            Future.delayed(const Duration(milliseconds: 900), () {
              LayerX.dismissAll();
              LayerX.toast('All dialogs dismissed');
            });
          }),

          /// ================= Context 模式测试 =================
          const _SectionTitle('Context Mode (no global init needed)'),
          _btn('toast (context mode)', () {
            LayerX.toast('This is context mode toast', context: context);
          }),
          _btn('confirm (context mode)', () async {
            final r = await LayerX.confirm(
              'Confirm with context?',
              context: context,
            );
            LayerX.toast('Result: $r', context: context);
          }),
          _btn('loading (context mode)', () async {
            LayerX.loading(context: context, message: 'Context loading...');
            await Future.delayed(const Duration(seconds: 2));
            LayerX.dismissLoading();
          }),
          _btn('wrapLoading (context mode)', () async {
            await LayerX.wrapLoading(() async {
              await Future.delayed(const Duration(seconds: 1));
            }, context: context);
            LayerX.toast('Context wrapLoading done', context: context);
          }),
          _btn('bottomSheet (context mode)', () {
            LayerX.bottomSheet(
              Container(
                padding: const EdgeInsets.all(20),
                height: 150,
                child: const Center(child: Text('Context BottomSheet')),
              ),
              context: context,
            );
          }),

          /// ================= 综合演示 =================
          const _SectionTitle('Full Flow'),
          _btn('🔥 Full Flow Demo', () async {
            LayerX.toast('Start');

            final ok = await LayerX.confirm('Execute task?');
            if (!ok) return;

            final text = await LayerX.input(hint: 'Enter something');
            if (text == null || text.isEmpty) return;

            await LayerX.wrapLoading(() async {
              await Future.delayed(const Duration(seconds: 2));
            });

            LayerX.notification(title: 'Completed', message: 'Input: $text');
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _btn(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onPressed, child: Text(text)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}