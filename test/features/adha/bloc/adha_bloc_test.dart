import 'package:flutter_test/flutter_test.dart';
import 'package:wanzo/features/adha/bloc/adha_bloc.dart';
import 'package:wanzo/features/adha/bloc/adha_event.dart';
import 'package:wanzo/features/adha/bloc/adha_state.dart';
import 'package:wanzo/features/adha/repositories/adha_repository.dart';
import 'package:wanzo/features/adha/models/adha_message.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'adha_bloc_test.mocks.dart';

@GenerateMocks([AdhaRepository])

void main() {
  late AdhaBloc adhaBloc;
  late MockAdhaRepository mockRepository;

  setUp(() {
    mockRepository = MockAdhaRepository();
    when(mockRepository.getConversations()).thenAnswer((_) async => <AdhaConversation>[]);
    when(mockRepository.getConversation(any)).thenAnswer((_) async => null);
    when(mockRepository.saveConversation(any)).thenAnswer((_) async { return; });
    when(mockRepository.deleteConversation(any)).thenAnswer((_) async { return; });
    when(mockRepository.sendMessage(conversationId: anyNamed('conversationId'), message: anyNamed('message'))).thenAnswer((_) async => '');
    adhaBloc = AdhaBloc(adhaRepository: mockRepository);
  });

  tearDown(() {
    adhaBloc.close();
  });

  group('AdhaBloc', () {
    test('initial state is correct', () {
      expect(adhaBloc.state, equals(const AdhaInitial()));
    });

    test('emits [AdhaLoading, AdhaConversationsList] when conversations are loaded', () async {
      final expectedStates = [
        const AdhaLoading(),
        AdhaConversationsList(const []),
      ];
      expectLater(
        adhaBloc.stream,
        emitsInOrder(expectedStates),
      );
      adhaBloc.add(const LoadConversations());
    });
  });
}
