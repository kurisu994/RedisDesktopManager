#pragma once
#include <QObject>
#include <QRegularExpression>
#include <QSharedPointer>

#include <qredisclient/connection.h>

namespace BulkOperations {

// 将通配符模式转换为 QRegularExpression
inline QRegularExpression wildcardToRegex(const QString& pattern) {
  return QRegularExpression(
      QRegularExpression::wildcardToRegularExpression(pattern));
}

class AbstractOperation : public QObject {
  Q_OBJECT

 public:
  enum class State { READY, RUNNING, FINISHED };

  typedef std::function<void(QRegularExpression affectedKeysFilter, long processed,
                             const QStringList& errors)>
      OperationCallback;

 public:
  AbstractOperation(QSharedPointer<RedisClient::Connection> connection,
                    int dbIndex, OperationCallback callback,
                    QRegularExpression keyPattern = wildcardToRegex("*"));

  virtual ~AbstractOperation() {}

  virtual void getAffectedKeys(std::function<void(QVariant, QString)> callback);

  virtual void run(QSharedPointer<RedisClient::Connection> targetConnection =
                       QSharedPointer<RedisClient::Connection>(),
                   int targetDbIndex = 0);

  virtual QString getTypeName() const = 0;

  virtual bool multiConnectionOperation() const = 0;

  bool isRunning() const;

  QSharedPointer<RedisClient::Connection> getConnection();

  int getDbIndex() const;

  QRegularExpression getKeyPattern() const;

  void setKeyPattern(const QRegularExpression p);

  int currentProgress() const;

  void setMetadata(const QVariantMap& meta);

 signals:
  void progress(int processed);

 protected:
  virtual bool isMetadataValid() const { return true; }

  virtual void performOperation(
      QSharedPointer<RedisClient::Connection> targetConnection,
      int targetDbIndex) = 0;

  void incrementProgress();

  void processError(const QString& err);

 protected:
  QSharedPointer<RedisClient::Connection> m_connection;
  int m_dbIndex;
  QRegularExpression m_keyPattern;
  State m_currentState;
  int m_progress;
  QList<QByteArray> m_affectedKeys;
  QList<QByteArray> m_keysWithErrors;
  QVariantMap m_metadata;
  OperationCallback m_callback;
  QStringList m_errors;
  QMutex m_errorsMutex;
  QMutex m_processedKeysMutex;
  qint64 m_lastProgressNotification;
  QString m_errorMessagePrefix;
};
}  // namespace BulkOperations
