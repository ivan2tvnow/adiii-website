databaseChangeLog = {

	changeSet(author: "shihpeng (generated)", id: "1370443201604-1") {
		createTable(tableName: "campaign") {
			column(autoIncrement: "true", name: "id", type: "bigint") {
				constraints(nullable: "false", primaryKey: "true", primaryKeyName: "campaignPK")
			}

			column(name: "version", type: "bigint") {
				constraints(nullable: "false")
			}

			column(name: "created_datetime", type: "timestamp") {
				constraints(nullable: "false")
			}

			column(name: "currency", type: "varchar(255)") {
				constraints(nullable: "false")
			}

			column(name: "daily_budget", type: "integer") {
				constraints(nullable: "false")
			}

			column(name: "end_datetime", type: "timestamp") {
				constraints(nullable: "false")
			}

			column(name: "has_end_datetime", type: "boolean") {
				constraints(nullable: "false")
			}

			column(name: "name", type: "varchar(30)") {
				constraints(nullable: "false")
			}

			column(name: "start_datetime", type: "timestamp") {
				constraints(nullable: "false")
			}
		}
	}

	changeSet(author: "shihpeng (generated)", id: "1370443201604-2") {
		createTable(tableName: "creative") {
			column(autoIncrement: "true", name: "id", type: "bigint") {
				constraints(nullable: "false", primaryKey: "true", primaryKeyName: "creativePK")
			}

			column(name: "version", type: "bigint") {
				constraints(nullable: "false")
			}

			column(name: "campaign_id", type: "bigint") {
				constraints(nullable: "false")
			}

			column(name: "image_url", type: "varchar(255)") {
				constraints(nullable: "false")
			}

			column(name: "text", type: "varchar(35)") {
				constraints(nullable: "false")
			}
		}
	}

	changeSet(author: "shihpeng (generated)", id: "1370443201604-3") {
		addForeignKeyConstraint(baseColumnNames: "campaign_id", baseTableName: "creative", constraintName: "FK6C816FAFE4B88C94", deferrable: "false", initiallyDeferred: "false", referencedColumnNames: "id", referencedTableName: "campaign", referencesUniqueColumn: "false")
	}
}
