import 'package:material_ui/material_ui.dart';
import 'package:layerx/layerx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: LayerX.init(),
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

    /// 👉 全局配置（丝滑体验）
    LayerX.config(
      delay: const Duration(milliseconds: 150),
      minShow: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LayerX Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ================= Dialog =================
          _btn('confirm', () async {
            final r = await LayerX.confirm('Are you sure to continue?');
            LayerX.toast('Result: $r');
          }),

          _btn('show', () async {
            LayerX.show("This is a message");
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
                          const Text('You can put any widget here '),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  LayerX.dismiss(context, "ok");
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // ✅ 返回数据
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
          }),

          /// ================= Bottom =================
          _btn('bottomSheet ⭐', () {
            LayerX.bottomSheet(
              Container(
                padding: const EdgeInsets.all(20),
                child: const Text('This is a BottomSheet'),
              ),
            );
          }),

          _btn('actionSheet ⭐', () async {
            final i = await LayerX.actionSheet(
              options: ['Camera', 'Gallery', 'Delete'],
            );
            LayerX.toast('Selected: $i');
          }),

          /// ================= Loading =================
          _btn('loading（manual）', () async {
            LayerX.loading();
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
          _btn('progress ⭐', () async {
            for (int i = 0; i <= 10; i++) {
              LayerX.progress(i / 10);
              await Future.delayed(const Duration(milliseconds: 200));
            }
            LayerX.dismissProgress();
          }),

          /// ================= Toast =================
          _btn('toast', () {
            LayerX.toast('This is a toast');

            // LayerX.toast('这是 Toast', fromBottom: false);

            // 自定义显示时间
            // LayerX.toast('长时间Confirm', duration: const Duration(seconds: 4));
          }),

          _btn('notification', () {
            LayerX.notification(
              title: 'New Message',
              message: 'You have an unread message',
            );
          }),

          /// ================= 综合 =================
          _btn('🔥 Full Flow Demo', () async {
            LayerX.toast('开始');

            final ok = await LayerX.confirm('Execute task?');

            if (!ok) return;

            final text = await LayerX.input();
            if (text == null) return;

            await LayerX.wrapLoading(() async {
              await Future.delayed(const Duration(seconds: 2));
            });

            LayerX.notification(title: 'Completed', message: 'Input: $text');
          }),
        ],
      ),
    );
  }

  Widget _btn(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
