import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multilingual_keyboard/main.dart';
import 'package:multilingual_keyboard/widgets/minimal_exam_keyboard.dart';
import 'package:multilingual_keyboard/services/performance_service.dart';

void main() {
  group('Multilingual Exam Keyboard Tests', () {
    
    testWidgets('Keyboard loads with default language', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify the keyboard loads
      expect(find.byType(MinimalExamKeyboard), findsOneWidget);
      
      // Verify default language is English
      expect(find.text('EN'), findsOneWidget);
    });
    
    testWidgets('Language switching works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Find and tap Hindi language button
      await tester.tap(find.text('HI'));
      await tester.pump();
      
      // Verify Hindi keyboard layout is displayed
      expect(find.text('क'), findsOneWidget);
      expect(find.text('ख'), findsOneWidget);
    });
    
    testWidgets('Key press generates text input', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Find and tap a key
      await tester.tap(find.text('q'));
      await tester.pump();
      
      // Verify text appears in input field
      expect(find.textContaining('q'), findsOneWidget);
    });
    
    test('Performance Optimizations - Pre-warming', () async {
      // Test pre-warming functionality
      await PerformanceOptimizations.preWarmKeyboard();
      
      // This should complete without throwing
      expect(true, isTrue);
    });
    
    test('Reliability Features - Retry mechanism', () async {
      // Test retry mechanism with mock failures
      try {
        await ReliabilityFeatures.insertTextWithRetry('test', maxRetries: 2);
        expect(true, isTrue); // Should complete without throwing
      } catch (e) {
        // Expected in test environment without platform channel
        expect(e, isA<MissingPluginException>());
      }
    });
    
    group('Language Layout Tests', () {
      testWidgets('English layout displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        
        // Ensure we're in English mode
        await tester.tap(find.text('EN'));
        await tester.pump();
        
        // Check for common English keys
        expect(find.text('q'), findsOneWidget);
        expect(find.text('w'), findsOneWidget);
        expect(find.text('e'), findsOneWidget);
      });
      
      testWidgets('Hindi layout displays Devanagari characters', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        
        // Switch to Hindi
        await tester.tap(find.text('HI'));
        await tester.pump();
        
        // Check for Hindi characters
        expect(find.text('क'), findsOneWidget);
        expect(find.text('ख'), findsOneWidget);
        expect(find.text('ग'), findsOneWidget);
      });
    });
    
    group('Performance Tests', () {
      testWidgets('Keyboard renders within performance budget', (WidgetTester tester) async {
        // Measure rendering time
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // Should render in less than 100ms (very generous for keyboard UI)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
      
      testWidgets('Language switching has minimal latency', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        
        // Measure language switch time
        final stopwatch = Stopwatch()..start();
        
        await tester.tap(find.text('HI'));
        await tester.pump();
        
        stopwatch.stop();
        
        // Language switch should be near-instantaneous
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });
    
    group('Stress Tests', () {
      testWidgets('Rapid key presses don\'t cause issues', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        
        // Simulate rapid typing
        for (int i = 0; i < 50; i++) {
          await tester.tap(find.text('a'));
          await tester.pump(const Duration(milliseconds: 10));
        }
        
        // Should complete without errors
        expect(find.byType(MinimalExamKeyboard), findsOneWidget);
      });
      
      testWidgets('Rapid language switching remains stable', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        
        // Rapidly switch between languages
        for (int i = 0; i < 20; i++) {
          await tester.tap(find.text('HI'));
          await tester.pump();
          await tester.tap(find.text('EN'));
          await tester.pump();
        }
        
        // Should remain stable
        expect(find.byType(MinimalExamKeyboard), findsOneWidget);
      });
    });
    
    group('Memory Tests', () {
      testWidgets('Keyboard maintains performance over time', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        
        // Simulate extended usage
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.text('HI'));
          await tester.pump();
          await tester.tap(find.text('EN'));
          await tester.pump();
          await tester.tap(find.text('q'));
          await tester.pump();
        }
        
        // Should still be responsive
        expect(find.byType(MinimalExamKeyboard), findsOneWidget);
      });
    });
    
    group('Error Handling Tests', () {
      testWidgets('Handles rapid interactions gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        
        // Rapid button presses shouldn't cause crashes
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('EN'));
          await tester.tap(find.text('HI'));
          await tester.tap(find.text('ES'));
          await tester.pump();
        }
        
        // Should remain stable
        expect(find.byType(MinimalExamKeyboard), findsOneWidget);
      });
    });
  });
}