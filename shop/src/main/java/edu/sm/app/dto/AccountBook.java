package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AccountBook {
  private Long id;
  private String userId;
  private String transactionDate;
  private String category;
  private Double amount;
  private String type;
  private String memo;
  private String currency;
}

// DTO의 date를 localdatetime으로 바꿔도되고
// DB의 currency에 환전 이후의 값인 KRW만 저장되는데 memo에서 따로 저장하거나 지워도 상관없음
//create table accountbook
//    (
//        id               bigserial
//        primary key,
//        user_id          varchar(50)    not null,
//transaction_date date           not null,
//category         varchar(50)    not null,
//amount           numeric(15, 2) not null,
//type             varchar(20)    not null,
//memo             varchar(500),
//created_at       timestamp   default CURRENT_TIMESTAMP,
//currency         varchar(10) default 'KRW'::character varying
//);
//
//alter table accountbook
//owner to postgres;

