# Generated by Django 2.2.7 on 2020-02-06 15:06

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('hdr', '0011_auto_20200206_1506'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='hojaderuta',
            name='importe_ampliacion_pendiente',
        ),
        migrations.RemoveField(
            model_name='hojaderuta',
            name='importe_contrato_pendiente',
        ),
        migrations.RemoveField(
            model_name='hojaderuta',
            name='importe_coste_directo_total',
        ),
    ]