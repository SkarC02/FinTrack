const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notificarIngresoNuevo = functions.firestore
  .document("ingresos/{ingresoId}")
  .onCreate(async (snap, context) => {
    try {
      const ingreso = snap.data();
      const monto = ingreso.monto ?? 0;
      const tipo = ingreso.tipo ?? "ingreso";
      const memberName = ingreso.memberName ?? "Un miembro";

      const tiposLabel = {
        diezmo: "Diezmo",
        ofrenda: "Ofrenda",
        donacion: "Donación",
        primicia: "Primicia",
        misiones: "Misiones",
      };

      const tipoLabel = tiposLabel[tipo] ?? tipo;

      const tokens = await getTokensParaRoles(["admin", "tesorero", "pastor"]);
      console.log(`Tokens encontrados: ${tokens.length}`);

      if (tokens.length === 0) {
        console.log("No hay tokens registrados");
        return null;
      }

      const mensaje = {
        notification: {
          title: `💰 Nuevo ${tipoLabel}`,
          body: `${memberName} registró L. ${monto.toFixed(2)}`,
        },
        tokens: tokens,
      };

      const response = await admin.messaging().sendEachForMulticast(mensaje);
      console.log(`Éxito: ${response.successCount}, Fallos: ${response.failureCount}`);
      return null;
    } catch (error) {
      console.error("Error en notificarIngresoNuevo:", error);
      return null;
    }
  });

exports.notificarGastoNuevo = functions.firestore
  .document("gastos/{gastoId}")
  .onCreate(async (snap, context) => {
    try {
      const gasto = snap.data();
      const monto = gasto.monto ?? 0;
      const descripcion = gasto.descripcion ?? "Gasto";

      const tokens = await getTokensParaRoles(["admin", "tesorero", "pastor"]);
      console.log(`Tokens encontrados: ${tokens.length}`);

      if (tokens.length === 0) {
        console.log("No hay tokens registrados");
        return null;
      }

      const mensaje = {
        notification: {
          title: `📤 Nuevo Gasto`,
          body: `${descripcion}: L. ${monto.toFixed(2)}`,
        },
        tokens: tokens,
      };

      const response = await admin.messaging().sendEachForMulticast(mensaje);
      console.log(`Éxito: ${response.successCount}, Fallos: ${response.failureCount}`);
      return null;
    } catch (error) {
      console.error("Error en notificarGastoNuevo:", error);
      return null;
    }
  });

async function getTokensParaRoles(roles) {
  const tokens = [];
  for (const rol of roles) {
    const snap = await admin
      .firestore()
      .collection("usuarios")
      .where("rol", "==", rol)
      .where("activo", "==", true)
      .get();

    for (const doc of snap.docs) {
      const token = doc.data().fcmToken;
      if (token && token.length > 0) {
        tokens.push(token);
      }
    }
  }
  return tokens;
}