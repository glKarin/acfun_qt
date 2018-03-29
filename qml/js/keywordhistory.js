.pragma library

var db_version = "1.0";

var db = openDatabaseSync("AcFun_KeywordHistory", "", "AcFun Search Keyword History Database", 1000);

if (db.version !== db_version){
    var change = function (tx){
        tx.executeSql('DROP TABLE IF EXISTS KeywordHistory');
        tx.executeSql('CREATE TABLE IF NOT EXISTS KeywordHistory(keyword TEXT UNIQUE)');
    }
    db.changeVersion(db.version, db_version, change);
} else {
    var trans = function(tx){
        tx.executeSql('CREATE TABLE IF NOT EXISTS KeywordHistory(keyword TEXT UNIQUE)');
    }
    db.transaction(trans);
}

function storeHistory(key){
    db.transaction(function(tx){
					tx.executeSql('DELETE FROM KeywordHistory WHERE keyword = \'%1\''.arg(key));
                       tx.executeSql('INSERT OR REPLACE INTO KeywordHistory VALUES (?)', [key]);
                   });
}

function removeOneHistory(key){
    db.transaction(function(tx){
					tx.executeSql('DELETE FROM KeywordHistory WHERE keyword = \'%1\''.arg(key));
                   });
}

function loadHistory(model){
    model.clear();
    db.readTransaction(function(tx){
                           var rs = tx.executeSql('SELECT * FROM KeywordHistory');
                           for (var i=rs.rows.length-1; i>=0; i--){
                               model.append({name: rs.rows.item(i).keyword});
                           }
                       })
}

function clearHistory(){
    db.transaction(function(tx){
                       tx.executeSql('DELETE FROM KeywordHistory');
                   })
}

function getHistorySize(){
	var rd = 0;
	var rs;
	db.readTransaction(function(tx){
		try{
			rs = tx.executeSql('SELECT COUNT(1) as \'count\' FROM KeywordHistory');
			if(rs.rows.length === 1)
				rd = rs.rows.item(0).count;
		}catch(e){
			rd = 0;
		}
	});
	return rd;
}
