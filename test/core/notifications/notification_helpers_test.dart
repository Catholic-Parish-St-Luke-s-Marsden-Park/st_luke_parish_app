import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/notifications/notification_constants.dart';
import 'package:st_luke_parish_app/core/notifications/notification_helpers.dart';

void main() {
  group('generateId', () {
    test('derives a stable id from the message id', () {
      const message = RemoteMessage(messageId: 'abc-123');

      final id = NotificationHelpers.generateId(message);

      expect(id, 'abc-123'.hashCode & 0x7fffffff);
      expect(NotificationHelpers.generateId(message), id);
    });

    test('masks the id into the signed 32-bit range the platform channel '
        'expects, not just .abs()', () {
      // A hash outside the 32-bit range would previously throw a
      // ClassCastException on the native side; & 0x7fffffff always fits.
      const message = RemoteMessage(messageId: 'a-message-id-with-a-large-hash');

      final id = NotificationHelpers.generateId(message);

      expect(id, inInclusiveRange(0, 0x7fffffff));
    });

    test('falls back to a non-negative id when there is no message id', () {
      const message = RemoteMessage();

      expect(
        NotificationHelpers.generateId(message),
        inInclusiveRange(0, 0x7fffffff),
      );
    });
  });

  group('encodePayload', () {
    test('returns null for empty data', () {
      expect(NotificationHelpers.encodePayload(const {}), isNull);
    });

    test('encodes non-empty data as JSON', () {
      final payload = NotificationHelpers.encodePayload(const {
        'screen': 'news',
        'id': '42',
      });

      expect(payload, '{"screen":"news","id":"42"}');
    });

    test('returns null instead of throwing for unencodable data', () {
      final payload = NotificationHelpers.encodePayload({'bad': Object()});

      expect(payload, isNull);
    });
  });

  group('getTitle', () {
    test('prefers the notification block title', () {
      const message = RemoteMessage(
        notification: RemoteNotification(title: 'From notification'),
        data: {'title': 'From data'},
      );

      expect(NotificationHelpers.getTitle(message), 'From notification');
    });

    test('falls back to the data payload for data-only messages', () {
      const message = RemoteMessage(data: {'title': 'From data'});

      expect(NotificationHelpers.getTitle(message), 'From data');
    });

    test('falls back to the default title when both are absent', () {
      const message = RemoteMessage();

      expect(
        NotificationHelpers.getTitle(message),
        NotificationConstants.defaultTitle,
      );
    });

    test('falls back to the default title when both are empty', () {
      const message = RemoteMessage(
        notification: RemoteNotification(title: ''),
        data: {'title': ''},
      );

      expect(
        NotificationHelpers.getTitle(message),
        NotificationConstants.defaultTitle,
      );
    });

    test('trims surrounding whitespace', () {
      const message = RemoteMessage(
        notification: RemoteNotification(title: '  Bulletin  '),
      );

      expect(NotificationHelpers.getTitle(message), 'Bulletin');
    });
  });

  group('getBody', () {
    test('prefers the notification block body', () {
      const message = RemoteMessage(
        notification: RemoteNotification(body: 'From notification'),
        data: {'body': 'From data'},
      );

      expect(NotificationHelpers.getBody(message), 'From notification');
    });

    test('falls back to the data payload for data-only messages', () {
      const message = RemoteMessage(data: {'body': 'From data'});

      expect(NotificationHelpers.getBody(message), 'From data');
    });

    test('falls back to the default body when both are absent', () {
      const message = RemoteMessage();

      expect(
        NotificationHelpers.getBody(message),
        NotificationConstants.defaultBody,
      );
    });
  });
}
