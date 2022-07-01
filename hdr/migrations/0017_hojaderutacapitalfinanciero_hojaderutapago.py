# Generated by Django 2.2.7 on 2022-07-01 14:47

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('hdr', '0016_auto_20200630_1542'),
    ]

    operations = [
        migrations.CreateModel(
            name='HojaDeRutaPago',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('importe_anterior', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago hasta fin del año anterior')),
                ('importe_presente', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago del presente año')),
                ('importe_mes_1', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago para el primer mes del cuatrimestre')),
                ('importe_mes_2', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago para el segundo mes del cuatrimestre')),
                ('importe_mes_3', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago para el tercer mes del cuatrimestre')),
                ('importe_mes_4', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago para el cuarto mes del cuatrimestre')),
                ('importe_resto', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago para el resto del año')),
                ('importe_proximo', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago para el próximo año')),
                ('importe_siguiente', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago para el siguiente año al próximo')),
                ('importe_pendiente', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de pago para el resto de años')),
                ('hoja', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='pago', to='hdr.HojaDeRuta', verbose_name='hoja de ruta')),
            ],
            options={
                'verbose_name': 'pago de hoja de ruta',
                'verbose_name_plural': 'pagos de hojas de ruta',
            },
        ),
        migrations.CreateModel(
            name='HojaDeRutaCapitalFinanciero',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('importe_anterior', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero hasta fin del año anterior')),
                ('importe_presente', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero del presente año')),
                ('importe_mes_1', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero para el primer mes del cuatrimestre')),
                ('importe_mes_2', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero para el segundo mes del cuatrimestre')),
                ('importe_mes_3', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero para el tercer mes del cuatrimestre')),
                ('importe_mes_4', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero para el cuarto mes del cuatrimestre')),
                ('importe_resto', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero para el resto del año')),
                ('importe_proximo', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero para el próximo año')),
                ('importe_siguiente', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero para el siguiente año al próximo')),
                ('importe_pendiente', models.DecimalField(blank=True, decimal_places=2, max_digits=14, null=True, verbose_name='importe de capital financiero para el resto de años')),
                ('hoja', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='capital_financiero', to='hdr.HojaDeRuta', verbose_name='hoja de ruta')),
            ],
            options={
                'verbose_name': 'capital financiero de hoja de ruta',
                'verbose_name_plural': 'capitales financieros de hojas de ruta',
            },
        ),
    ]
