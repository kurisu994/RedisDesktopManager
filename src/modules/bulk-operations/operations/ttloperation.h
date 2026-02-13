#pragma once
#include <asyncfuture.h>
#include <QObject>
#include <QRegularExpression>
#include <QSharedPointer>
#include "abstractoperation.h"

namespace BulkOperations {

class TtlOperation : public AbstractOperation {
  Q_OBJECT
 public:
  TtlOperation(QSharedPointer<RedisClient::Connection> connection, int dbIndex,
               OperationCallback callback,
               QRegularExpression keyPattern = wildcardToRegex("*"));

  QString getTypeName() const override { return QString("ttl"); }

  bool multiConnectionOperation() const override { return false; }

  bool isMetadataValid() const override { return m_metadata.contains("ttl"); }

 protected:
  void performOperation(
      QSharedPointer<RedisClient::Connection> targetConnection,
      int targetDbIndex) override;


  void setTtl(const QList<QByteArray> &keys, const QByteArray &ttl, std::function<void()> callback);
};
}  // namespace BulkOperations
